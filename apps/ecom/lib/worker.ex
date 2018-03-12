defmodule Ecom.Worker do
  @moduledoc """
  Module that offer does Logic functions work.
  """

  import Ecto.Query, only: [from: 2]

  alias Comeonin.Argon2
  alias Ecom.Accounts.{User, Product, Cart, CartProduct, Order, ProductOrder}
  alias Ecom.{Repo, Accounts, ProductValues}

  def update_user(user, params_password, attrs, :password_needed) do
    with true <- Argon2.checkpw(params_password, user.password_digest),
         {:ok, %User{}} <- Accounts.update_user(user, attrs, []) do
      {:ok, :accept}
    else
      false ->
        {:error, :wrong_pass}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def update_user(user, _, attrs, :no_password) do
    case Accounts.update_user(user, attrs, :no_password) do
      {:ok, %User{}} -> {:ok, :accept}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def create_product(user, params) do
    with :ok <- Bodyguard.permit(Product, :create_products, user),
         {:ok, %Product{} = product} = Accounts.create_product(params) do
      {:ok, product}
    else
      {:error, changeset} -> {:error, changeset}
    end
  end

  def sign_in(username, password) do
    User
    |> Repo.get_by(username: username)
    |> do_sign_in(password)
  end

  defp do_sign_in(nil, _password) do
    {:error, :failed}
  end

  defp do_sign_in(user, password) do
    if Argon2.checkpw(password, user.password_digest) do
      # Starts the state for product values added to cart
      ProductValues.start_link(user.id)

      {:ok, user}
    else
      Argon2.dummy_checkpw()
      {:error, :failed}
    end
  end

  def new_user(user_params) do
    with {:ok, user} <- Accounts.create_user(user_params),
         {:ok, %Cart{}} <- Accounts.create_cart(%{user_id: user.id}) do
      {:ok, user}
    else
      {:error, changeset} -> {:error, changeset}
    end
  end

  # When a payment is complete.
  def empty_user_cart(user, sess_proc_id, param_proc_id) do
    with true <- sess_proc_id == param_proc_id,
         :ok <- remove_user_products(user.cart.id, user.cart.products) do
      {:ok, :empty}
    else
      false -> {:error, :invalid_proc_id}
      {:error, _changeset} -> {:error, :unable_to_empty}
    end
  end

  # Removes association when a product is deleted.
  defp remove_user_products(cart_id, products) do
    Enum.each(products, fn product ->
      query = from(p in CartProduct, where: [cart_id: ^cart_id], where: [product_id: ^product.id])

      query
      |> Repo.one()
      |> Repo.delete()
    end)
  end

  # Empties user cart, clean ProductValues state, removes quantity from product
  def after_payment(user, sess_proc_id, param_proc_id) do
    case empty_user_cart(user, sess_proc_id, param_proc_id) do
      {:ok, :empty} ->
        do_post_payment_process(user)

        {:ok, :empty}

      {:error, error} ->
        {:error, error}
    end
  end

  defp do_post_payment_process(%{id: id}) do
    values = ProductValues.get_all_values(id)

    Enum.each(values, fn {id, map} -> modify_product_quantity(id, map.value) end)

    ProductValues.clean_state_for(id)
  end

  defp modify_product_quantity(id, value) do
    product = Accounts.get_product!(id)
    attrs = %{quantity: product.quantity - value}

    Accounts.update_product(product, attrs)
  end

  # Zips product and value into a tuple
  def zip_from(products, nil) do
    # Get the valid products for the session (If a product was deleted)
    valid_prods = get_valid_products(products)

    do_zip_from(valid_prods)
  end

  def zip_from(products, user_id) do
    values = ProductValues.get_all_values(user_id)

    for product <- products,
        {id, val} <- values do
      if product.id == id, do: {product, val.value}
    end
    |> Enum.reject(&is_nil/1)
  end

  defp get_valid_products(products) do
    Enum.reduce(products, [], fn product, acc ->
      case Repo.get(Product, product.id) do
        nil -> acc
        _ -> acc ++ [product]
      end
    end)
  end

  defp do_zip_from(session_products) do
    new_products =
      Enum.map(session_products, fn product ->
        {Accounts.get_product!(product.id), product.value}
      end)

    {session_products, new_products}
  end

  # Check personal information about a user
  def address_has_nil_field(user) do
    # Check if field is nil
    user_attrs =
      user
      |> Map.take(~w(address country city zip_code)a)
      |> Map.values()

    nil in user_attrs
  end

  def update_product(id, params) do
    product = Accounts.get_product!(id)

    case Accounts.update_product(product, params) do
      {:ok, %Product{} = product} -> {:ok, product}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def delete_product(id) do
    product = Accounts.get_product!(id)

    case Accounts.delete_product(product) do
      {:ok, %Product{}} -> {:ok, :deleted}
      {:error, _} -> {:error, :unable_to_delete}
    end
  end
end
