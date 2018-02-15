defmodule EcomWeb.CartController do
  @moduledoc false

  use EcomWeb, :controller

  alias Ecom.Accounts
  alias Cart.Interfaces.SingleCart

  def index(conn, _params) do
    user_cart = conn.cookies["user_cart_name"]
    products_in_cart = SingleCart.show_cart(user_cart)

    render(conn, "index.html", products: products_in_cart)
  end

  def add_to_cart(conn, %{"product" => id, "curr_path" => path}) do
    {user_cart, _, product_params} = get_params_and_cart_name(conn, id)

    case SingleCart.add_to_cart(user_cart, product_params) do
      :added ->
        conn
        |> put_flash(:success, gettext("Product added to cart"))
        |> redirect(to: path)
      :already_added ->
        conn
        |> put_flash(:warning, gettext("Product is already in the cart"))
        |> redirect(to: path)
    end
  end

  def delete_product(conn, %{"id" => id}) do
    {user_cart, _product, product_params} = get_params_and_cart_name(conn, id)

    SingleCart.remove_from_cart(user_cart, product_params)

    conn
    |> put_flash(:success, gettext("Removed from cart"))
    |> redirect(to: cart_path(conn, :index))
  end

  defp get_params_and_cart_name(conn, id) do
    product = Accounts.get_product!(id)
    product_params = Map.take(product, ~w(id name description quantity user_id)a)
    user_cart = conn.cookies["user_cart_name"]

    {user_cart, product, product_params}
  end
end
