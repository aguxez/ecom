defmodule Ecom.CartTask do
  @moduledoc false

  # TODO: Disable add to cart button if product is already in cart

  alias Ecom.{Accounts, Repo, ProductValues}
  alias Ecom.Accounts.CartProducts

  def add_to_db_cart(conn, user, [product]) do
    cart_products = user.cart.products
    attrs = %{product_id: product["id"], cart_id: user.cart.id}

    # Save the value of the product
    ProductValues.save_value_for(user.id, product)

    with false <- product_in_cart(cart_products, product),
         {:ok, _} <- Accounts.create_cart_product(attrs) do

      {conn, :added}
    else
      true -> {conn, :already_added}
      {:error, _} -> {conn, :error}
    end
  end

  defp product_in_cart(cart, product) do
    ids = Enum.map(cart, fn x -> x.id end)
    product["id"] in ids
  end

  #######
  def delete_db_cart_product(conn, %{id: user_id}, %{"id" => product_id}) do
    product = Repo.get_by(CartProducts, product_id: product_id)

    case Accounts.delete_cart_product(product) do
      {:ok, _} ->
        ProductValues.remove_from(user_id, product_id)
        {conn, :removed}

      {:error, _} ->
        {conn, :failed}
    end
  end

  def db_update_cart_values(conn, %{id: user_id}, products_to_update) do
    Enum.each(products_to_update, fn {id, val} ->
      attrs = %{"id" => String.to_integer(id), "value" => String.to_integer(val)}

      ProductValues.save_value_for(user_id, attrs)
    end)

    {:ok, conn}
  end
end
