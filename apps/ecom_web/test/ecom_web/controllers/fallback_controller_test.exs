defmodule EcomWeb.FallbackControllerTest do
  @moduledoc false

  use EcomWeb.ConnCase

  # To test this module we're going to create a normal user and call an endpoint
  # that requires more perms then make sure that the FallbackController was called.
  setup do
    user =
      :user
      |> build()
      |> encrypt_password("password")
      |> insert()

    {:ok, user: user, conn: build_conn()}
  end

  test "Action is called", %{conn: conn, user: user} do
    conn =
      conn
      |>sign_in(user)
      |> get(admin_path(conn, :index))

    assert get_flash(conn, :alert) == "No autorizado"
    assert redirected_to(conn) == page_path(conn, :index)
  end

  defp sign_in(conn, user),
    do: EcomWeb.Auth.Guardian.Plug.sign_in(conn, user)
end
