defmodule EcomWeb.ProductControllerTest do
  @moduledoc false

  use EcomWeb.ConnCase

  setup do
    user =
      :user
      |> build()
      |> encrypt_password("password")
      |> insert()

    product = insert(:product, user_id: user.id)

    {:ok, product: product, conn: build_conn()}
  end

  test "show.html shows product", %{conn: conn, product: product} do
    conn = get(conn, product_path(conn, :show, product.id))

    assert conn.status == 200
    assert html_response(conn, 200) =~ product.name
    assert html_response(conn, 200) =~ product.description
  end
end
