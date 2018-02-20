defmodule EcomWeb.Helpers do
  @moduledoc false

  def current_user(conn) do
    user = Ecom.Guardian.Plug.current_resource(conn)

    unless user == nil, do: user
  end

  # Define 'fields' to get from 'user'
  def current_user(conn, fields) do
    user = Ecom.Guardian.Plug.current_resource(conn)

    unless user == nil, do: Map.take(user, fields)
  end

  def get_csrf_token do
    Plug.CSRFProtection.get_csrf_token()
  end
end
