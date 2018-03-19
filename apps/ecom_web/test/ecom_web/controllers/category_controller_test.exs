defmodule EcomWeb.CategoryControllerTest do
  @moduledoc false

  use EcomWeb.ConnCase

  setup do
    user = insert(:user)
    conn = sign_in(build_conn(), user)

    {:ok, conn: conn, user: user}
  end

  test "renders new.html page", %{conn: conn} do
    conn = get(conn, category_path(conn, :new))

    assert conn.status == 200
    assert html_response(conn, 200) =~ "Create a category"
  end

  test "creates a category", %{conn: conn} do
    attrs = %{name: "New category"}
    conn = post(conn, category_path(conn, :create), category: attrs)

    assert conn.status == 302
    assert redirected_to(conn) == page_path(conn, :index)
    assert get_flash(conn, :success) == "Category created!"
  end

  test "couldn't create category", %{conn: conn} do
    attrs = %{something: :else}
    conn = post(conn, category_path(conn, :create), category: attrs)

    assert conn.status == 200
    assert html_response(conn, 200) =~ "Create a category"
    assert get_flash(conn, :alert) == "We couldn't create your category"
  end

  defp sign_in(conn, user) do
    EcomWeb.Auth.Guardian.Plug.sign_in(conn, user)
  end
end
