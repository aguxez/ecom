defmodule EcomWeb.SessionControllerTest do
  @moduledoc false

  # TODO: FIX TESTS

  use EcomWeb.ConnCase

  alias Cart.Interfaces.{SingleCart, SingleCartSup}
  alias Ecom.Accounts.{User}
  alias Ecom.{Repo, Accounts}

  setup do
    info =
      %{
        username: "test",
        password: "testing_password",
        password_confirmation: "testing_password",
        email: "some@email.com",
      }

    SingleCartSup.start_child("cart3")
    {:ok, user} = Accounts.create_user(info)
    Accounts.create_cart(%{user_id: user.id})


    {:ok, conn: build_conn(), user: user}
  end

  test "shows the login form", %{conn: conn} do
    conn = get(conn, session_path(conn, :new))

    assert html_response(conn, 200) =~ "Iniciar sesión"
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

  test "when user is logged in the cart is moved to db and memory is emptied", %{conn: conn, user: user} do
    assert :added == SingleCart.add_to_cart("cart3", %{"name" => "something"}, [logged: false])
    assert [%{"name" => "something"}] == SingleCart.show_cart("cart3", [logged: false])

    conn =
      conn
      |> get("/")
      |> do_post(%{username: "test", password: "testing_password"})

    conn = SingleCart.sign_in_and_remove(conn, "cart3", [logged: true, user: Repo.preload(user, :cart)])

    assert [] == SingleCart.show_cart("cart3", [logged: false])
    assert [%{"name" => "something"}] == SingleCart.show_cart("cart3", [logged: true, user: Repo.preload(user, :cart)])

    assert conn.status == 302
    assert redirected_to(conn) == page_path(conn, :index)
  end

  # Perform 'post' request.
  defp do_post(conn, attrs) do
    post(conn, session_path(conn, :create), user: attrs)
  end
end
