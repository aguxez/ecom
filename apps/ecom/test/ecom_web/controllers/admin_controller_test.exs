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

      admin_user=
        user
        |> Changeset.change(is_admin: true)
        |> Repo.update!()

      {:ok, conn: build_conn(), user: admin_user}
    end

    test "path exists", %{conn: conn} do
      conn = get(conn, admin_path(conn, :index))

      assert conn.status == 401 # since we're not allowed
      assert conn.path_info == ["site_settings"]
      assert conn.request_path == "/site_settings"
    end

    test "can be accessed by admins", %{user: user} do
      assert :ok == Bodyguard.permit(User, :admin_panel, user)
    end

    test "can't be accessed by users", %{user: user} do
      normal_user =
        user
        |> Changeset.change(is_admin: false)
        |> Repo.update!()

      assert {:error, :unauthorized} = Bodyguard.permit(User, :admin_panel, normal_user)
      refute :ok == Bodyguard.permit(User, :admin_panel, normal_user)
    end
  end
end