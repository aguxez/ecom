defmodule EcomWeb.Plugs.RedirectTest do
  @moduledoc false

  use EcomWeb.ConnCase

  test "redirects a connection when specified in router", %{conn: conn} do
    conn = get(conn, "/pub")

    assert conn.status == 302
    assert redirected_to(conn) == product_path(conn, :index)
    assert conn.halted
  end
end
