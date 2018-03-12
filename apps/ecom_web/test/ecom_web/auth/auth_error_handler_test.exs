defmodule EcomWeb.Auth.AuthErrorHandlerTest do
  @moduledoc false

  use EcomWeb.ConnCase

  setup do
    {:ok, conn: build_conn()}
  end

  test "redirects on unauthorized users", %{conn: conn} do
    conn = get(conn, admin_path(conn, :index))

    assert get_flash(conn, :alert) == "Por favor, inicia sesión primero"
    assert redirected_to(conn) == session_path(conn, :new)
    assert html_response(conn, 302) =~ "redirected"
  end
end
