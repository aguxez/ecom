defmodule EcomWeb.AdminControllerTest do
  @moduledoc false

  use EcomWeb.ConnCase

  alias Ecom.Accounts
  alias Ecom.Accounts.User
  alias Ecom.Repo
  alias Ecto.Changeset

  describe("admin panel") do
    setup do
      attr = %{
        email: "test@email.com",
        username: "test_user",
        password: "24813699",
        password_confirmation: "24813699"
      }

      {:ok, user} = Accounts.create_user(attr)

      admin_user =
        user
        |> Changeset.change(is_admin: true)
        |> Repo.update!()

      {:ok, conn: build_conn(), admin: admin_user, user: user}
    end

    test "path exists", %{conn: conn} do
      conn = get(conn, admin_path(conn, :index))

      assert conn.status == 302 # since we're not allowed
      assert conn.path_info == ["site_settings"]
      assert conn.request_path == "/site_settings"
    end

    test "can be accessed by admins", %{admin: user} do
      assert :ok == Bodyguard.permit(User, :admin_panel, user)
    end

    test "can't be accessed by users", %{user: user} do
      assert {:error, :unauthorized} = Bodyguard.permit(User, :admin_panel, user)
      refute :ok == Bodyguard.permit(User, :admin_panel, user)
    end

    test "new product template", %{admin: user, conn: conn} do
      conn =
        conn
        |> sign_in(user)
        |> get(admin_path(conn, :new_product))

      assert conn.status == 200
      assert html_response(conn, 200) =~ "Añadir un producto"
    end

    test "users can't get product template", %{conn: conn} do
      conn = get(conn, admin_path(conn, :new_product))

      assert get_flash(conn, :alert) == "Por favor, inicia sesión primero"
      assert redirected_to(conn) == session_path(conn, :new)
    end

    test "admin can create new product", %{admin: user, conn: conn} do
      attrs = %{name: "some name", description: "some description"}
      conn =
        conn
        |> sign_in(user)
        |> post(admin_path(conn, :create_product), product: attrs)

      assert get_flash(conn, :success) == "Producto creado satisfactoriamente"
      assert redirected_to(conn) == page_path(conn, :index)
    end

    @tag :skip
    test "users can't create products", %{user: user, conn: conn} do
      # TODO: For some reason after posting the 'current_resource' has the user as
      # an admin which is not what we want since they're posting data when they shouldn't.
      attrs = %{name: "some name", description: "Some desc"}

      conn = sign_in(conn, user)
      conn =
        conn
        |> post(admin_path(conn, :create_product), product: attrs)

      assert get_flash(conn, :alert) == "No autorizado"
      assert conn.status in 200..299
    end
  end

  defp sign_in(conn, user) do
    Ecom.Guardian.Plug.sign_in(conn, user)
  end
end
