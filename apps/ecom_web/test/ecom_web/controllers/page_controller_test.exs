defmodule EcomWeb.PageControllerTest do
  use EcomWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    # Just the main react "div"
    assert html_response(conn, 200) =~ "LOGGED-IN USER"
  end
end
