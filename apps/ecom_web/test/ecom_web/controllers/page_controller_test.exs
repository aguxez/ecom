defmodule EcomWeb.PageControllerTest do
  use EcomWeb.ConnCase

  setup do
    user =
      :user
      |> build()
      |> encrypt_password("password")
      |> insert

    insert(:cart, user_id: user.id)

    {:ok, user: user}
  end

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    # Just the main react "div"
    assert conn.status == 200
  end

  test "user_token gets set on assigns", %{conn: conn, user: user} do
    conn =
      conn
      |> sign_in(user)
      |> get("/")

    assert conn.assigns[:user_token]
  end

  defp sign_in(conn, user) do
    EcomWeb.Auth.Guardian.Plug.sign_in(conn, user)
  end
end
