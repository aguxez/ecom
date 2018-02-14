defmodule EcomWeb.PageController do
  @moduledoc false

  use EcomWeb, :controller

  alias Ecom.Accounts
  alias Cart.Interfaces.SingleCartSup

  action_fallback EcomWeb.FallbackController

  def index(conn, _params) do
    [request_id] = Plug.Conn.get_resp_header(conn, "x-request-id")
    products = Accounts.list_products()

    if conn.cookies["user_cart_name"] do
      SingleCartSup.start_child(conn.cookies["user_cart_name"])

      render(conn, "index.html", products: products)
    else
      conn = put_resp_cookie(conn, "user_cart_name", request_id)

      SingleCartSup.start_child(conn.cookies["user_cart_name"])

      render(conn, "index.html", products: products)
    end
  end
end
