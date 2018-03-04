defmodule Ecom.Worker do
  @moduledoc false

  import Ecto.Query, only: [from: 2]

  alias Comeonin.Argon2
  alias Ecom.Accounts.{User, Product, Cart}
  alias Ecom.{Repo, Accounts, ProductValues}

  def update_user(user, params_password, attrs) do
    with true <- Argon2.checkpw(params_password, user.password_digest),
         {:ok, %User{}} <- Accounts.update_user(user, attrs) do
      {:ok, :accept}
    else
      false ->
        {:error, :wrong_pass}

      {:error, changeset} ->
        {:error, changeset}
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

  def empty_user_cart(user, sess_proc_id, param_proc_id) do
    with true <- sess_proc_id == param_proc_id,
         {:ok, %Cart{}} <- Accounts.update_cart(user.cart, %{products: %{}}) do
      {:ok, :empty}
    else
      false -> {:error, :invalid_proc_id}
      {:error, _changeset} -> {:error, :unable_to_empty}
    end
  end

  # Zips product and value into a tuple
  def zip_from(products, user_id) do
    values = ProductValues.get_all_values(user_id)

    for product <- products, {id, val} <- values do
      if product.id == id, do: {product, val["value"]}
    end
    |> Enum.reject(&is_nil/1)
  end
end
