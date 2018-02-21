defmodule EcomWeb.LayoutViewTest do
  use EcomWeb.ConnCase, async: true

  alias Ecom.Accounts.User
  alias Ecom.{Repo}
  alias EcomWeb.Helpers

  setup do
    user =
      :user
      |> build()
      |> encrypt_password("password")
      |> insert()

    insert(:cart, user_id: user.id)

    {:ok, conn: build_conn(), user: user}
  end

  test "current_user returns the user in the session", %{conn: conn, user: user} do
    conn = sign_in(conn, user)

    assert Helpers.current_user(conn)
  end

  test "current_user returns nothing if there is no user in the current session", %{conn: conn, user: user} do
    user = Repo.get_by(User, %{username: user.username})
    conn = delete(conn, session_path(conn, :delete, user))

    refute EcomWeb.Helpers.current_user(conn)
  end

  defp sign_in(conn, user) do
    Ecom.Guardian.Plug.sign_in(conn, user)
  end
end
