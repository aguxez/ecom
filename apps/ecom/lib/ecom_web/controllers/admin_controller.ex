defmodule EcomWeb.AdminController do
  @moduledoc false

  use EcomWeb, :controller

  alias Ecom.Accounts.User

  plug Bodyguard.Plug.Authorize,
    policy: User,
    action: :admin_panel,
    user: &Guardian.Plug.current_resource/1,
    fallback: EcomWeb.FallbackController

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
