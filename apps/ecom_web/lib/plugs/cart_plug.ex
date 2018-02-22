defmodule EcomWeb.Plugs.CartPlug do
  @moduledoc """
  Module that checks the conn to see if the Cart was initialized.
  """

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    user_cart = get_session(conn, :user_cart)

    if user_cart do
      conn
    else
      put_session(conn, :user_cart, %{})
    end
  end
end
