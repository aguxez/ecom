defmodule EcomWeb.CartControllerTest do
  @moduledoc false

  use EcomWeb.ConnCase

  setup do
    # First we get the 'user_cart_name' from the 'index' cookie.
    conn = build_conn()
    conn = get(conn, page_path(conn, :index))

    user =
      :user
      |> build()
      |> encrypt_password("password")
      |> insert()

    insert(:cart, user_id: user.id)

    # The product we're going to add
    product = insert(:product, user_id: user.id)

    {:ok, conn: conn, product: product, user: user}
  end

  test "adds product to cart", %{conn: conn, product: product} do
    # Since we don't need to sign-in to add products to our cart.
    conn = do_post(conn, product)

    assert conn.status == 302
    assert get_flash(conn, :success) == "Producto añadido al carrito"
    assert redirected_to(conn) == page_path(conn, :index)
  end

  test "can't duplicate product", %{conn: conn, product: product} do
    conn = do_post(conn, product)
    conn = do_post(conn, product)

    assert conn.status == 302
    assert get_flash(conn, :warning) == "El producto ya está en el carrito"
    assert redirected_to(conn) == page_path(conn, :index)
  end

  test "deletes product from cart", %{conn: conn, product: product} do
    conn = do_delete(conn, product)

    assert conn.status == 302
    assert get_flash(conn, :success) == "Producto removido del carrito"
    assert redirected_to(conn) == cart_path(conn, :index)
  end

  test "retrieves the correct product on session cart", %{conn: conn, product: product} do
    conn = do_post(conn, product)

    assert get_session(conn, :user_cart) == %{product.id => %{id: product.id, value: 1}}
  end

  test "state of session cart on product delete", %{conn: conn, product: product} do
    conn =
      conn
      |> do_post(product)
      |> do_delete(product)

    assert get_session(conn, :user_cart) == %{}
  end

  test "shows correct cart on index.html", %{conn: conn, product: product} do
    conn = do_post(conn, product)
    conn = get(conn, cart_path(conn, :index))

    assert conn.status == 200
    assert html_response(conn, 200) =~ product.name
    assert html_response(conn, 200) =~ "1" # Default value of a product when added to a cart as string because of HTML.
  end

  defp do_post(conn, product) do
    post(
      conn,
      cart_path(conn, :add_to_cart),
      product: product.id,
      curr_path: page_path(conn, :index)
    )
  end

  defp do_delete(conn, product) do
    delete(conn, cart_path(conn, :delete_product, product.id))
  end
end
