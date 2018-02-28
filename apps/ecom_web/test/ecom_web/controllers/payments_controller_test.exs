defmodule EcomWeb.PaymentsControllerTest do
  @moduledoc false

  use EcomWeb.ConnCase

  setup do
    bypass = Bypass.open()
    user = insert(:user)

    {:ok, bypass: bypass, user: user}
  end

  test "post payment", %{bypass: bypass, user: user, conn: conn} do
    Bypass.expect(bypass, fn conn ->
      Plug.Conn.send_resp(conn, 200, "")
    end)

    conn =
      conn
      |> sign_in(user)
      |> post(payments_path(conn, :create), stripeToken: conn_url(bypass.port))

    assert get_flash(conn, :success) == "Payment done!"
    assert redirected_to(conn) == cart_path(conn, :index)
  end

  test "failed payment", %{bypass: bypass, user: user, conn: conn} do
    Bypass.expect(bypass, fn conn ->
      Plug.Conn.send_resp(conn, 500, "")
    end)

    conn =
      conn
      |> sign_in(user)
      |> post(payments_path(conn, :create), stripeToken: conn_url(bypass.port))

    assert get_flash(conn, :alert) == "There was an error processing your payment"
    assert redirected_to(conn) == cart_path(conn, :index)
  end

  defp sign_in(conn, user) do
    EcomWeb.Auth.Guardian.Plug.sign_in(conn, user)
  end

  defp conn_url(port), do: "http://localhost:#{port}/payments"
end
