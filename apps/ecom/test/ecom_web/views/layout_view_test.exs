defmodule EcomWeb.LayoutViewTest do
  use EcomWeb.ConnCase, async: true

  alias Ecom.Accounts.User
  alias Ecom.{Repo, Accounts}
  alias EcomWeb.Helpers

  setup do
    info =
      %{
        email: "someeee@email.com",
        username: "agu",
        password: "testing_password",
        password_confirmation: "testing_password",
      }

    {:ok, user} = Accounts.create_user(info)
    {:ok, _} = Accounts.create_cart(%{user_id: user.id})

    {:ok, conn: build_conn()}
  end

  @tag :skip
  test "current_user returns the user in the session", %{conn: conn} do
    conn = post(conn, session_path(conn, :create), user: %{username: "agu", password: "testing_password"})

    assert Helpers.current_user(conn)
  end

  test "current_user returns nothing if there is no user in the current session", %{conn: conn} do
    user = Repo.get_by(User, %{username: "agu"})
    conn = delete(conn, session_path(conn, :delete, user))

    refute EcomWeb.Helpers.current_user(conn)
  end
end
