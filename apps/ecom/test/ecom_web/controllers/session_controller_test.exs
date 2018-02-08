defmodule EcomWeb.SessionControllerTest do
  @moduledoc false

  use EcomWeb.ConnCase

  alias Ecom.Accounts.{User}
  alias Ecom.Repo

  setup do
    info =
      %{
        username: "test",
        password: "testing_password",
        password_confirmation: "testing_password",
        email: "some@email.com",
      }

    %User{}
    |> User.changeset(info)
    |> Repo.insert()


    {:ok, conn: build_conn()}
  end

  test "shows the login form", %{conn: conn} do
    conn = get(conn, session_path(conn, :new))

    assert html_response(conn, 200) =~ "Inicia Sesión"
  end

  test "creates a new user session for a valid user", %{conn: conn} do
    conn = do_post(conn, %{username: "test", password: "testing_password"})

    assert Ecom.Guardian.Plug.current_resource(conn)
    assert get_flash(conn, :success) == "¡Sesión iniciada satisfactoriamente!"
    assert redirected_to(conn) == page_path(conn, :index)
  end

  test "does't create a session on bad login", %{conn: conn} do
    conn = do_post(conn, %{username: "test", password: "eigthcharacterpassword"})

    refute get_session(conn, :current_user)
    assert get_flash(conn, :alert) == "¡Nombre de usuario o contraseña incorrectos!"
    assert redirected_to(conn) == session_path(conn, :new)
  end

  test "does not create a session if user does not exist", %{conn: conn} do
    conn = do_post(conn, %{username: "foo", password: "testing_password"})

    assert get_flash(conn, :alert) == "¡Nombre de usuario o contraseña incorrectos!"
    assert redirected_to(conn) == session_path(conn, :new)
  end

  test "deletes the user session", %{conn: conn} do
    user = Repo.get_by(User, %{username: "test"})
    conn = delete(conn, session_path(conn, :delete, user))

    refute get_session(conn, :current_user)
    assert get_flash(conn, :success) == "Sesión cerrada satisfactoriamente"
    assert redirected_to(conn) == page_path(conn, :index)
  end

  # Perform 'post' request.
  defp do_post(conn, attrs) do
    post(conn, session_path(conn, :create), user: attrs)
  end
end
