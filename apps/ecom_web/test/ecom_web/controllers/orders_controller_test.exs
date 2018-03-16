defmodule EcomWeb.OrdersControllerTest do
  @moduledoc false

  use EcomWeb.ConnCase

  alias Ecom.Repo

  setup do
    user = insert(:user)
    user =
      user
      |> Ecto.Changeset.change(%{is_admin: true})
      |> Repo.update!()

    order = insert(:order, user_id: user.id)

    {:ok, order: order, user: user}
  end

  test "index renders list of orders", %{conn: conn, order: order, user: user} do
    conn =
      conn
      |> sign_in(user)
      |> get(orders_path(conn, :index))

    assert conn.status == 200
    assert html_response(conn, 200) =~ orders_path(conn, :show, order.id)
    assert html_response(conn, 200) =~ "Orders"
  end

  test "show renders an order", %{conn: conn, order: order, user: user} do
    order = Repo.preload(order, [:user, :products])
    conn =
      conn
      |> sign_in(user)
      |> get(orders_path(conn, :show, order.id))

    assert conn.status == 200
    assert html_response(conn, 200) =~ order.user.username
    assert html_response(conn, 200) =~ order.user.email
  end

  test "mass_updates given orders", %{conn: conn, user: user} do
    orders = insert_list(4, :order, user_id: user.id)
    attrs =
      for order <- orders, into: %{} do
        # Worker receives ids as integers already
        {order.id, "pending"}
      end

    conn =
      conn
      |> sign_in(user)
      |> get(orders_path(conn, :change_status, attrs))

    assert conn.status == 302
    assert get_flash(conn, :success) == "Orders updated"
    assert redirected_to(conn) == orders_path(conn, :index)
  end

  test "returns error on mass_update_orders", %{conn: conn, user: user} do
    attrs = %{1 => "completed"}
    conn =
      conn
      |> sign_in(user)
      |> get(orders_path(conn, :change_status, attrs))

    assert conn.status == 302
    assert get_flash(conn, :warning) == "There was an error while trying to update the orders"
    assert redirected_to(conn) == orders_path(conn, :index)
  end

  defp sign_in(conn, user), do: EcomWeb.Auth.Guardian.Plug.sign_in(conn, user)
end
