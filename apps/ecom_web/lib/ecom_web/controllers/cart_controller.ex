defmodule EcomWeb.CartController do
  @moduledoc false

  use EcomWeb, :controller

  alias Ecom.{Repo}
  alias Ecom.Interfaces.{Accounts, CartTask}

  def index(conn, _params) do
    products_in_cart = show_cart(conn)

    render(conn, "index.html", products: products_in_cart)
  end

  defp show_cart(conn) do
    curr_user = preloaded_user(conn)

    if curr_user do
      Map.values(curr_user.cart.products)
    else
      # If the user is not logged in then the item is added to the key ':user_cart' in session.
      Map.values(get_session(conn, :user_cart))
    end
  end

  def add_to_cart(conn, %{"product" => id, "curr_path" => path}) do
    {_user_cart, _, product_params} = get_params_and_cart_name(conn, id)
    cart_operation = add_to_cart(conn, product_params)

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

  def add_to_cart(conn, product) do
    curr_user = preloaded_user(conn)
    # 'to_map_string' is a private function
    string_map = to_map_string(product)
    new_product = Enum.map([string_map], &Map.put(&1, "value", 1))

    if curr_user do
      CartTask.add_to_db_cart(conn, curr_user, new_product)
    else
      add_to_session_cart(conn, new_product)
    end
  end

  defp add_to_session_cart(conn, [product]) do
    products = get_session(conn, :user_cart)

    # 'product' is a list already, we need to get the first element.
    if Map.has_key?(products, product["id"]) do
      {conn, :already_added}
    else
      conn = put_session(conn, :user_cart, Map.merge(products, %{product["id"] => product}))
      {conn, :added}
    end
  end

  def delete_product(conn, %{"id" => id}) do
    {_user_cart, _product, product_params} = get_params_and_cart_name(conn, id)

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

  defp do_delete_product(conn, product) do
    curr_user = preloaded_user(conn)

    if curr_user do
      CartTask.delete_db_cart_product(conn, curr_user, product)
    else
      products = get_session(conn, :user_cart)
      {_, new_params} = Map.pop(products, product["id"])
      conn = put_session(conn, :user_cart, new_params)

      {conn, :removed}
    end
  end

  # When the 'Save' or 'Pay' button are clicked.
  def process_cart(conn, %{"submit" => submit_val} = params) do
    case submit_val do
      "save" -> update_cart_values(conn, params)
      "pay"  -> make_cart_payment(conn)
    end
  end

  defp update_cart_values(conn, params) do
    curr_user = preloaded_user(conn)
    # Probably theres a better way of constructing these params
    # Puts a map without the '_utf8' and 'submit' keys under :products key.
    attrs = Map.drop(params, ~w(_utf8 submit))
    user_cart = get_session(conn, :user_cart)

    new_conn =
      if curr_user do
        CartTask.db_update_cart_values(conn, curr_user, attrs)
      else
        session_update_cart_values(conn, user_cart, attrs)
      end

    case new_conn do
      {:ok, conn} ->
        conn
        |> put_flash(:success, gettext("Your cart has been saved!"))
        |> redirect(to: cart_path(conn, :index))

      {:error, conn} ->
        conn
        |> put_flash(:alert, gettext("There was a problem trying to save your cart"))
        |> redirect(to: cart_path(conn, :index))
    end
  end

  defp session_update_cart_values(conn, user_cart, products_to_update) do
    updated_values =
      Enum.reduce(products_to_update, user_cart, fn({k, v}, acc) ->
        id = String.to_integer(k)
        put_in(acc, [id, "value"], v)
      end)

    {:ok, put_session(conn, :user_cart, updated_values)}
  end

  defp make_cart_payment(conn) do
    path =
      if current_user(conn) do
        payments_path(conn, :index)
      else
        session_path(conn, :new)
      end

    redirect(conn, to: path)
  end

  # More used privs
  defp preloaded_user(conn) do
    conn
    |> current_user()
    |> Repo.preload(:cart)
  end

  # Converts atom keys to strings for the given product.
  defp to_map_string(product) do
    for {k, v} <- product, into: %{}, do: {to_string(k), v}
  end

  # Get a triplet of information, probably can be overriden.
  defp get_params_and_cart_name(conn, id) do
    user_cart = get_session(conn, :user_cart_name)
    product = Accounts.get_product!(id)
    product_params =
      product
      |> Map.take(~w(id name description quantity user_id)a)
      |> to_map_string()

    {user_cart, product, product_params}
  end
end
