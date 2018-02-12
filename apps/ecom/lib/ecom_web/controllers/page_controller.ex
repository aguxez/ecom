defmodule EcomWeb.PageController do
  @moduledoc false

  use EcomWeb, :controller

  action_fallback EcomWeb.FallbackController

  def index(conn, _params) do
    token = Plug.CSRFProtection.get_csrf_token()

    render(conn, "index.html", csrf_token: token)
  end
end
