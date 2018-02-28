defmodule Ecomweb.AccountControllerTest do
  @moduledoc false

  use EcomWeb.ConnCase

  describe "account controller" do
    setup do
      user =
        :user
        |> build()
        |> encrypt_password("password")
        |> insert()

      {:ok, user: user, conn: build_conn()}
    end

    test "renders index.html", %{conn: conn, user: user} do
      conn =
        conn
        |> sign_in(user)
        |> get(account_path(conn, :index))

      assert conn.request_path == "/account"
      assert conn.status == 200
      assert html_response(conn, 200) =~ "Actualiza tu contraseña"
      assert EcomWeb.Auth.Guardian.Plug.current_resource(conn)
    end

    test "can update user information", %{conn: conn, user: user} do
      new_params = %{
        password: "password",
        new_password: "m2481369",
        new_password_confirmation: "m2481369"
      }

      conn =
        conn
        |> sign_in(user)
        |> patch(account_path(conn, :update, user.id), user: new_params)

      assert get_flash(conn, :success) == "Cuenta actualizada correctamente"
      assert redirected_to(conn) == account_path(conn, :index)
    end

    test "returns error on invalid password", %{conn: conn, user: user} do
      new_params = %{
        password: "passwordd",
        new_password: "m2481369",
        new_password_confirmation: "m2481369"
      }

      conn =
        conn
        |> sign_in(user)
        |> patch(account_path(conn, :update, user.id), user: new_params)

      assert get_flash(conn, :warning) == "Contraseña actual incorrecta"
      assert redirected_to(conn) == account_path(conn, :index)
    end

    # @tag :skip
    test "returns error on invalid information", %{conn: conn, user: user} do
      new_params = %{
        password: "password",
        new_password: "m2481369",
        new_password_confirmation: "m2481394"
      }

      conn =
        conn
        |> sign_in(user)
        |> patch(account_path(conn, :update, user.id), user: new_params)

      assert get_flash(conn, :alert) == "No se pudo actualizar tu cuenta"
      assert html_response(conn, 200) =~ "Actualiza tu contraseña"
    end
  end

  defp sign_in(conn, user) do
    EcomWeb.Auth.Guardian.Plug.sign_in(conn, user)
  end
end
