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

  defp sign_in(conn, user), do: EcomWeb.Auth.Guardian.Plug.sign_in(conn, user)
end
