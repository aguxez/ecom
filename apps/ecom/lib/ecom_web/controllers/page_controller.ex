defmodule EcomWeb.PageController do
  @moduledoc false

  use EcomWeb, :controller

  alias Ecom.Accounts.User

  action_fallback EcomWeb.FallbackController

  def index(conn, _params) do
    token = Plug.CSRFProtection.get_csrf_token()

    render(conn, "index.html", csrf_token: token)
  end

  def secret(conn, _params) do
    user = Guardian.Plug.current_resource(conn)

    with :ok <- Bodyguard.permit(User, :admin_panel, user),
      do: render(conn, "secret.html")
  end
end
