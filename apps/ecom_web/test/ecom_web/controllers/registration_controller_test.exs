defmodule EcomWeb.RegistrationControllerTest do
  @moduledoc false

  use EcomWeb.ConnCase

  describe "registration tests" do
    setup do
      {:ok, conn: build_conn()}
    end

    test "renders index.html", %{conn: conn} do
      conn = get(conn, registration_path(conn, :new))

      assert html_response(conn, 200) =~ "Registrate"
      assert conn.status == 200
      assert conn.request_path == "/register/new"
    end

    test "creates a new user", %{conn: conn} do
      conn = post(conn, registration_path(conn, :create), user: params_for(:user))

      assert get_flash(conn, :success) == "Cuenta creada satisfactoriamente"
      assert EcomWeb.Auth.Guardian.Plug.current_resource(conn)
      assert redirected_to(conn) == page_path(conn, :index)
    end

    test "doesn't create user with invalid params", %{conn: conn} do
      attrs = %{
        email: "something",
        username: "user",
        password: "1234",
        password_confirmation: "12412"
      }

      conn = post(conn, registration_path(conn, :create), user: attrs)

      assert get_flash(conn, :alert) == "Hubieron unos problemas al intentar registrar tu cuenta"
    end
  end
end
