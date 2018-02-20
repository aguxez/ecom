defmodule EcomWeb.CartController do
  @moduledoc false

  # TODO: Products should be deleted from carts when they're deleted.
  # TODO: Reorganize functions structure

  use EcomWeb, :controller


  alias Ecom.Repo
  alias Ecom.Accounts
  alias Cart.Interfaces.SingleCart

  def index(conn, _params) do
    products_in_cart = show_cart(conn)

    render(conn, "index.html", products: products_in_cart)
  end

  defp show_cart(conn) do
    curr_user = preloaded_user(conn)

    if curr_user do
      curr_user.cart.products
    else
      # If the user is not logged in then the item is added to the key ':user_cart' in session.
      get_session(conn, :user_cart)
    end
  end

  # For arity 3 functions
  defp do_add_to_cart(conn, product) do
    curr_user = preloaded_user(conn)
    # 'to_map_string' is a private function
    string_map = to_map_string(product)
    new_product = Enum.map([string_map], &Map.put(&1, "value", 1))

    if curr_user do
      do_add_to_db_cart(conn, curr_user, new_product)
    else
      add_to_session_cart(conn, new_product)
    end
  end

  defp do_add_to_db_cart(conn, user, product) do
    cart_products = user.cart.products
    attrs = %{products: cart_products ++ product}

    with false <- Enum.member?(cart_products, hd(product)),
         {:ok, _} <- Accounts.update_cart(user.cart, attrs) do

      {conn, :added}
    else
      true -> {conn, :already_added}
      {:error, _} -> {conn, :error}
    end
  end

  defp preloaded_user(conn) do
    conn
    |> current_user("everything")
    |> Repo.preload(:cart)
  end

  defp add_to_session_cart(conn, product) do
    products = get_session(conn, :user_cart)

    # 'product' is a list already, we need to get the first element.
    if Enum.find(products, &Map.get(&1, "id") == hd(product)["id"]) do
      {conn, :already_added}
    else
      conn = put_session(conn, :user_cart, products ++ product)
      {conn, :added}
    end
  end

  def add_to_cart(conn, %{"product" => id, "curr_path" => path}) do
    {_user_cart, _, product_params} = get_params_and_cart_name(conn, id)
    cart_operation = do_add_to_cart(conn, product_params)

    case cart_operation do
      {conn, :added} ->
        conn
        |> put_flash(:success, gettext("Product added to cart"))
        |> redirect(to: path)
      {conn, :already_added} ->
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

    cart_op = do_delete_product(conn, product_params)

    case cart_op do
      {conn, :removed} ->
        conn
        |> put_flash(:success, gettext("Removed from cart"))
        |> redirect(to: cart_path(conn, :index))
      {conn, :failed} ->
        conn
        |> put_flash(:alert, gettext("There was a problem removing the product from your cart"))
        |> redirect(to: cart_path(conn, :index))
    end
  end

  defp do_delete_product(conn, product_params) do
    curr_user = preloaded_user(conn)

    if curr_user do
      do_delete_db_cart_product(conn, curr_user, product_params)
    else
      products = get_session(conn, :user_cart)
      new_params = Enum.reject(products, &(&1["id"] == product_params["id"]))
      conn = put_session(conn, :user_cart, new_params)

      {conn, :removed}
    end
  end

  defp do_delete_db_cart_product(conn, user, product) do
    attrs = Enum.reject(user.cart.products, &(&1["id"] == product["id"]))

    case Accounts.update_cart(user.cart, %{products: attrs}) do
      {:ok, _} -> {conn, :removed}
      {:error, _} -> {conn, :failed}
    end
  end

  def process_cart(conn, %{"submit" => submit_val} = params) do
    case submit_val do
      "save" -> save_cart_values(conn, params)
      "pay"  -> :ok # TODO: Pay function
    end
  end

  defp save_cart_values(conn, params) do
    # Probably theres a better way of constructing these params
    attrs = Map.put(%{}, :products, Map.drop(params, ~w(_utf8 submit)))
    user_cart = get_session(conn, :user_cart_name)

    Enum.each(attrs.products, fn{k, v} ->
      SingleCart.update_value(user_cart, k, v, [logged: false])
    end)

    conn
    |> put_session(:user_cart_values, attrs)
    |> put_flash(:success, gettext("Your cart has been saved!"))
    |> redirect(to: cart_path(conn, :index))
  end

  # Get a triplet of information
  defp get_params_and_cart_name(conn, id) do
    user_cart = get_session(conn, :user_cart_name)
    product = Accounts.get_product!(id)
    product_params =
      product
      |> Map.take(~w(id name description quantity user_id)a)
      |> to_map_string()

    {user_cart, product, product_params}
  end

  # Converts atom keys to strings for the given product.
  defp to_map_string(product) do
    for {k, v} <- product, into: %{}, do: {to_string(k), v}
  end
end
