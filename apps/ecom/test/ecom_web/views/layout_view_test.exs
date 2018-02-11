defmodule EcomWeb.LayoutViewTest do
  use EcomWeb.ConnCase, async: true

  alias EcomWeb.LayoutView
  alias Ecom.Accounts.User
  alias Ecom.Repo

  setup do
    info =
      %{
        email: "some@email",
        username: "agu",
        password: "testing_password",
        password_confirmation: "testing_password",
      }

    %User{}
    |> User.changeset(info)
    |> Repo.insert()

    {:ok, conn: build_conn()}
  end

  test "current_user returns the user in the session", %{conn: conn} do
    conn = post(conn, session_path(conn, :create), user: %{username: "agu", password: "testing_password"})

    assert EcomWeb.Helpers.current_user(conn, "everything")
  end

  test "current_user returns nothing if there is no user in the current session", %{conn: conn} do
    user = Repo.get_by(User, %{username: "agu"})
    conn = delete(conn, session_path(conn, :delete, user))

    refute EcomWeb.Helpers.current_user(conn, "everything")
  end
end
