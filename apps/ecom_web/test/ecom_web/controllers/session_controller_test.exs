defmodule EcomWeb.SessionControllerTest do
  @moduledoc false

  # TODO: FIX TESTS

  use EcomWeb.ConnCase

  alias EcomWeb.Helpers

  setup do
    conn = build_conn()
    conn = get(conn, page_path(conn, :index))

    user =
      :user
      |> build()
      |> encrypt_password("password")
      |> insert()

    insert(:cart, user_id: user.id)

    {:ok, conn: conn, user: user}
  end

  test "shows the login form", %{conn: conn} do
    conn = get(conn, session_path(conn, :new))

    assert html_response(conn, 200) =~ "Iniciar sesión"
  end

  # Raising error for the Repo.preload function.
  test "creates a new user session for a valid user", %{conn: conn, user: user} do
    conn =
      conn
      |> recycle()
      |> sign_in(user)

    assert Helpers.current_user(conn)
  end

  test "does't create a session on bad login", %{conn: conn} do
    conn = do_post(conn, %{username: "asdjas", password: "password"})

    refute get_session(conn, :current_user)
    assert get_flash(conn, :alert) == "¡Nombre de usuario o contraseña incorrectos!"
    assert redirected_to(conn) == session_path(conn, :new)
  end

  test "does not create a session if user does not exist", %{conn: conn} do
    conn = do_post(conn, %{username: "foo", password: "testing_password"})

    assert get_flash(conn, :alert) == "¡Nombre de usuario o contraseña incorrectos!"
    assert redirected_to(conn) == session_path(conn, :new)
  end

  test "deletes the user session", %{conn: conn, user: user} do
    conn = delete(conn, session_path(conn, :delete, user))

    refute get_session(conn, :current_user)
    assert get_flash(conn, :success) == "Sesión cerrada satisfactoriamente"
    assert redirected_to(conn) == page_path(conn, :index)
  end

  # Perform 'post' request.
  defp do_post(conn, attrs) do
    conn
    |> post(session_path(conn, :create), user: attrs)
  end

  defp sign_in(conn, user) do
    EcomWeb.Auth.Guardian.Plug.sign_in(conn, user)
  end
end
