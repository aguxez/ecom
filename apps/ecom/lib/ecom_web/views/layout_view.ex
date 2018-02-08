defmodule EcomWeb.LayoutView do
  use EcomWeb, :view

  def current_user(conn) do
    Ecom.Guardian.Plug.current_resource(conn)
  end

  def get_csrf_token do
    Plug.CSRFProtection.get_csrf_token()
  end
end
