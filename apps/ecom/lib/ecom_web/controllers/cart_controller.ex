defmodule EcomWeb.CartController do
  @moduledoc false

  # TODO: Products should be deleted from carts when they're deleted.

  use EcomWeb, :controller


  alias Ecom.Repo
  alias Ecom.Accounts
  alias Cart.Interfaces.SingleCart

  def index(conn, _params) do
    user_cart = conn.cookies["user_cart_name"]

    products_in_cart = single_cart_user_action(conn, user_cart, &SingleCart.show_cart/2)

    render(conn, "index.html", products: products_in_cart)
  end

  # For arity 2 functions
  defp single_cart_user_action(conn, user_cart, fun) do
    curr_user = preloaded_user(conn)

    if curr_user do
      fun.(user_cart, [logged: true, user: curr_user])
    else
      fun.(user_cart, [logged: false])
    end
  end

  # For arity 3 functions
  defp single_cart_user_action(conn, user_cart, product, fun) do
    curr_user = preloaded_user(conn)
    new_product = for {k, v} <- product, into: %{}, do: {to_string(k), v}

    if curr_user do
      fun.(user_cart, new_product, [logged: true, user: curr_user])
    else
      fun.(user_cart, new_product, [logged: false])
    end
  end

  defp preloaded_user(conn) do
    conn
    |> current_user("everything")
    |> Repo.preload(:cart)
  end

  def add_to_cart(conn, %{"product" => id, "curr_path" => path}) do
    {user_cart, _, product_params} = get_params_and_cart_name(conn, id)
    cart_operation = single_cart_user_action(conn, user_cart, product_params, &SingleCart.add_to_cart/3)

    case cart_operation do
      :added ->
        conn
        |> put_flash(:success, gettext("Product added to cart"))
        |> redirect(to: path)
      :already_added ->
        conn
        |> put_flash(:warning, gettext("Product is already in the cart"))
        |> redirect(to: path)
      _ ->
        conn
        |> put_flash(:alert, gettext("There was a problem updating your cart"))
        |> redirect(to: path)
    end
  end

  def delete_product(conn, %{"id" => id}) do
    {user_cart, _product, product_params} = get_params_and_cart_name(conn, id)

    cart_op = single_cart_user_action(conn, user_cart, product_params, &SingleCart.remove_from_cart/3)

    case cart_op do
      :removed ->
        conn
        |> put_flash(:success, gettext("Removed from cart"))
        |> redirect(to: cart_path(conn, :index))
      :failed ->
        conn
        |> put_flash(:alert, gettext("There was a problem removing the product from your cart"))
        |> redirect(to: cart_path(conn, :index))
    end
  end

  # Get a triplet of information
  defp get_params_and_cart_name(conn, id) do
    product = Accounts.get_product!(id)
    product_params = Map.take(product, ~w(id name description quantity user_id)a)
    user_cart = conn.cookies["user_cart_name"]

    {user_cart, product, product_params}
  end
end
