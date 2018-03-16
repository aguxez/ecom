defmodule EcomWeb.OrdersController do
  @moduledoc false

  use EcomWeb, :controller

  alias Ecom.Interfaces.{Accounts, Worker}

  plug(
    Bodyguard.Plug.Authorize,
    policy: Ecom.Accounts.User,
    action: :admin_panel,
    user: &Guardian.Plug.current_resource/1,
    fallback: EcomWeb.FallbackController
  )

  def index(conn, _params) do
    pending_orders = Worker.orders_query("pending")
    completed_orders = Worker.orders_query("completed")
    denied_orders = Worker.orders_query("denied")

    render(conn, "index.html", pending_orders: pending_orders, completed_orders: completed_orders, denied_orders: denied_orders)
  end

  def show(conn, %{"id" => id}) do
    order = Accounts.get_order!(id)
    total = for({_, value} <- hd(order.values), do: value) |> Enum.count()

    render(conn, "show.html", order: order, total: total)
  end

  def change_status(conn, params) do
    params = Map.drop(params, ["_utf8"])
    data = for {key, value} <- params, into: %{}, do: {String.to_integer(key), value}

    case Worker.mass_update_orders(data) do
      {:ok, :updated} ->
        conn
        |> put_flash(:success, gettext("Orders updated"))
        |> redirect(to: orders_path(conn, :index))

      {:error, :unable_to_update} ->
        conn
        |> put_flash(:warning, gettext("There was an error while trying to update the orders"))
        |> redirect(to: orders_path(conn, :index))
    end
  end
end
