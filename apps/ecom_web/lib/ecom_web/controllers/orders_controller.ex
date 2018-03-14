defmodule EcomWeb.OrdersController do
  @moduledoc false

  use EcomWeb, :controller

  alias Ecom.Interfaces.Accounts

  plug(
    Bodyguard.Plug.Authorize,
    policy: Ecom.Accounts.User,
    action: :admin_panel,
    user: &Guardian.Plug.current_resource/1,
    fallback: EcomWeb.FallbackController
  )

  def index(conn, _params) do
    orders = Accounts.list_orders()

    render(conn, "index.html", orders: orders)
  end

  def show(conn, %{"id" => id}) do
    order = Accounts.get_order!(id)

    render(conn, "show.html", order: order)
  end
end
