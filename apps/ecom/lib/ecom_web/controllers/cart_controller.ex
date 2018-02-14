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

  def add_to_cart(conn, %{"product" => id}) do
    product = Accounts.get_product!(id)
    product_params = Map.take(product, ~w(id name description quantity user_id)a)
    user_cart = conn.cookies["user_cart_name"]

    SingleCart.add_to_cart(user_cart, product_params)

    redirect(conn, to: page_path(conn, :index))
  end
end
