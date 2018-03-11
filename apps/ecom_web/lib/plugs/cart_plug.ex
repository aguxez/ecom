defmodule EcomWeb.Plugs.CartPlug do
  @moduledoc """
  Module that checks the conn to see if the Cart was initialized.
  """

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    user_cart = get_session(conn, :user_cart)

    put_user_cart?(user_cart, conn)
  end

  defp put_user_cart?(nil, conn), do: put_session(conn, :user_cart, %{})
  defp put_user_cart?(_user_cart, conn), do: conn
end
