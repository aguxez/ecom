defmodule EcomWeb.LayoutView do
  use EcomWeb, :view

  def current_user(conn) do
    user = Ecom.Guardian.Plug.current_resource(conn)

    unless user == nil do
      # 'overall' is just a key to hide the is_admin field from React props.
      %{username: user.username, id: user.id, overall: user.is_admin}
    end
  end

  def get_csrf_token do
    Plug.CSRFProtection.get_csrf_token()
  end
end
