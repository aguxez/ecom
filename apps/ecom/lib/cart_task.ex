defmodule Ecom.CartTask do
  @moduledoc false

  alias Ecom.Accounts

  def add_to_db_cart(conn, user, [product]) do
    cart_products = user.cart.products
    attrs = %{products: Map.merge(cart_products, %{product["id"] => product})}

    # when 'product' is inserted in the db, the value gets turned into a String,
    # that's why we use 'to_string' here.
    with false <- Map.has_key?(cart_products, to_string(product["id"])),
         {:ok, _} <- Accounts.update_cart(user.cart, attrs) do

      {conn, :added}
    else
      true -> {conn, :already_added}
      {:error, _} -> {conn, :error}
    end
  end

  #######
  def delete_db_cart_product(conn, user, product) do
    {_, attrs} = Map.pop(user.cart.products, to_string(product["id"]))

    case Accounts.update_cart(user.cart, %{products: attrs}) do
      {:ok, _} -> {conn, :removed}
      {:error, _} -> {conn, :failed}
    end
  end

  def db_update_cart_values(conn, user, products_to_update) do
    updated_values =
      Enum.reduce(products_to_update, user.cart.products, fn({k, v}, acc) ->
        put_in(acc, [k, "value"], v)
      end)

    case Accounts.update_cart(user.cart, %{products: updated_values}) do
      {:ok, _} -> {:ok, conn}
      {:error, _} -> {:error, conn}
    end
  end
end
