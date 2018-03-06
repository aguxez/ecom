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

  test "disables button and shows text when product is in cart", %{conn: conn, product: product} do
    conn = do_post(conn, product)
    conn = get(conn, product_path(conn, :show, product.id))

    assert conn.status == 200
    assert html_response(conn, 200) =~ "This product is already in your cart"
    assert html_response(conn, 200) =~ "disabled=\"disabled\""
  end

  defp do_post(conn, product) do
    post(
      conn,
      cart_path(conn, :add_to_cart),
      product: product.id,
      curr_path: page_path(conn, :index)
    )
  end
end
