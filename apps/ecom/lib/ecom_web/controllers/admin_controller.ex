defmodule EcomWeb.AdminController do
  @moduledoc false

  use EcomWeb, :controller

  import Ecto.Query, only: [from: 2]

  alias Ecom.Accounts
  alias Ecom.Accounts.User
  alias Ecom.Repo

  plug Bodyguard.Plug.Authorize,
    policy: User,
    action: :admin_panel,
    user: &Guardian.Plug.current_resource/1,
    fallback: EcomWeb.FallbackController

  def index(conn, _params) do
    users_amount = length(Accounts.list_users())

    latest_users = Repo.all(from u in User, order_by: u.inserted_at)

    render(conn, "index.html", users_amount: users_amount, latest_users: latest_users)
  end
end
