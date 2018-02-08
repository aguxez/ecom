defmodule EcomWeb.PageController do
  use EcomWeb, :controller

  def index(conn, _params) do
    token = Plug.CSRFProtection.get_csrf_token()

    render(conn, "index.html", csrf_token: token)
  end

  def secret(conn, _params) do
    render(conn, "secret.html")
  end
end
