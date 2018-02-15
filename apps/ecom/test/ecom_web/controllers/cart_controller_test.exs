defmodule EcomWeb.CartControllerTest do
  @moduledoc false

  use EcomWeb.ConnCase

  alias Ecom.Accounts

  setup do
    # First we get the 'user_cart_name' from the 'index' cookie.
    conn = build_conn()
    conn = get(conn, page_path(conn, :index))

    user_attrs = %{
      email: "some@email.com",
      username: "test_username",
      password: "123456789",
      password_confirmation: "123456789"
    }

    {:ok, user} = Accounts.create_user(user_attrs)

    # The product we're going to add
    product_attrs = %{
      name: "name",
      description: "description",
      quantity: 123,
      user_id: user.id
    }

    {:ok, product} = Accounts.create_product(product_attrs)

    {:ok, conn: conn, product: product}
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

  defp do_post(conn, product) do
    post(conn, cart_path(conn, :add_to_cart), product: product.id, curr_path: page_path(conn, :index))
  end

  defp do_delete(conn, product) do
    delete(conn, cart_path(conn, :delete_product, product.id))
  end
end
