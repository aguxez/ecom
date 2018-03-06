defmodule EcomWeb.PaymentsControllerTest do
  @moduledoc false

  use EcomWeb.ConnCase

  setup do
    bypass = Bypass.open()

    user =
      :user
      |> build()
      |> encrypt_password("password")
      |> insert()

    insert(:cart, user_id: user.id)

    {:ok, bypass: bypass, user: user}
  end

  test "session variables get set on payments index", %{conn: conn, user: user} do
    conn =
      conn
      |> sign_in(user)
      |> get(payments_path(conn, :index))

    assert html_response(conn, 200) =~ "Total"
    assert get_session(conn, :proc_id)
  end

  test "process payment", %{conn: conn, user: user} do
    conn = conn |> get(page_path(conn, :index))
    proc = get_session(conn, :proc_id)

    conn =
      conn
      |> recycle()
      |> sign_in(user)
      |> get(payments_path(conn, :processed), proc_id: proc)

    assert get_flash(conn, :success) == "Payment made!"
  end

  test "redirects to login page if user isn't logged in", %{conn: conn} do
    conn = get(conn, payments_path(conn, :index))

    assert conn.status == 302
    assert redirected_to(conn) == session_path(conn, :new)
  end

  test "doesn't redirect if there's a user logged in", %{conn: conn, user: user} do
    conn =
      conn
      |> sign_in(user)
      |> get(payments_path(conn, :index))

    assert conn.status == 200
    assert html_response(conn, 200) =~ "Total"
  end

  defp sign_in(conn, user) do
    post(
      conn,
      session_path(conn, :create),
      user: %{username: user.username, password: "password"}
    )
  end

  # defp conn_url(port), do: "http://localhost:#{port}/payments"
end
