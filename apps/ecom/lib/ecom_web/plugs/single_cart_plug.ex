defmodule EcomWeb.Plugs.SingleCartPlug do
  @moduledoc """
  Module that checks the conn to see if the Cart was initialized.
  """

  import Plug.Conn

  alias Cart.Interfaces.SingleCartSup

  def init(opts), do: opts

  def call(conn, _opts) do
    [request_id] = get_resp_header(conn, "x-request-id")

    if conn.cookies["user_cart_name"] do
      SingleCartSup.start_child(conn.cookies["user_cart_name"])

      conn
    else
      conn = put_resp_cookie(conn, "user_cart_name", request_id)

      SingleCartSup.start_child(conn.cookies["user_cart_name"])

      conn
    end
  end
end
