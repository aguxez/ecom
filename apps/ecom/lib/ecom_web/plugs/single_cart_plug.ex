defmodule EcomWeb.Plugs.SingleCartPlug do
  @moduledoc """
  Module that checks the conn to see if the Cart was initialized.
  """

  import Plug.Conn

  alias Cart.Interfaces.SingleCartSup

  def init(opts), do: opts

  def call(conn, _opts) do
    [request_id] = get_resp_header(conn, "x-request-id")
    user_cart = get_session(conn, :user_cart)
    user_cart_name = get_session(conn, :user_cart_name)

    if user_cart do
      conn
    else
      put_session(conn, :user_cart, [])
    end

    # if user_cart do
    #   SingleCartSup.start_child(user_cart)

    #   conn
    # else
    #   conn = put_session(conn, :user_cart_name, request_id)

    #   SingleCartSup.start_child(user_cart)

    #   conn
    # end
  end
end
