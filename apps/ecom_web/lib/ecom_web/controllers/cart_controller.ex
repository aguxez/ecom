defmodule EcomWeb.CartController do
  @moduledoc false

  use EcomWeb, :controller

  alias Ecom.{Repo}
  alias Ecom.Interfaces.{Accounts, CartTask, Worker}

  def index(conn, _params) do
    {conn, products_in_cart} = show_cart(conn)

    render(conn, "index.html", products: products_in_cart)
  end

  defp show_cart(conn) do
    curr_user = preloaded_user(conn)

    if curr_user do
      {conn, Worker.zip_from(curr_user.cart.products, curr_user.id)}
    else
      # If the user is not logged in then the item is added to the key ':user_cart' in session.
      products =
        conn
        |> get_session(:user_cart)
        |> Map.values()

      {session_products, new_products} = Worker.zip_from(products, nil)

      # Puts available products into session and removes the ones which were deleted
      conn = put_session_cart_products(conn, session_products)

      {conn, new_products}
    end
  end

  defp put_session_cart_products(conn, session_products) do
    # Making the old session map structure again
    old_map = Enum.reduce(session_products, %{}, fn product, acc -> Map.merge(acc, %{product.id => product}) end)

    put_session(conn, :user_cart, old_map)
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

  defp do_add_to_cart(conn, product) do
    curr_user = preloaded_user(conn)
    new_product = Enum.map([product], &Map.put(&1, :value, 1))

    if curr_user do
      CartTask.add_to_db_cart(conn, curr_user, new_product)
    else
      add_to_session_cart(conn, new_product)
    end
  end

  defp add_to_session_cart(conn, [product]) do
    products = get_session(conn, :user_cart)

    # 'product' is a list already, we need to get the first element.
    if Map.has_key?(products, product.id) do
      {conn, :already_added}
    else
      conn = put_session(conn, :user_cart, Map.merge(products, %{product.id => product}))

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
      new_params = Map.delete(products, product.id)
      conn = put_session(conn, :user_cart, new_params)

      {conn, :removed}
    end
  end

  # When the 'Save' or 'Pay' button are clicked.
  def process_cart(conn, %{"submit" => submit_val} = params) do
    case submit_val do
      "save" -> update_cart_values(conn, params)
      "pay" -> make_cart_payment(conn)
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
      Enum.reduce(products_to_update, user_cart, fn {k, v}, acc ->
        id = String.to_integer(k)
        value = String.to_integer(v)
        # Make value an a String
        put_in(acc, [id, :value], value)
      end)

    {:ok, put_session(conn, :user_cart, updated_values)}
  end

  defp make_cart_payment(conn) do
    # Just checking if user is logged in
    check_before_payment(conn, current_user(conn))
  end

  defp check_before_payment(conn, nil) do
    conn
    |> put_flash(:warning, gettext("Please log-in first"))
    |> redirect(to: session_path(conn, :new))
  end
  defp check_before_payment(conn, _user) do
    redirect(conn, to: payments_path(conn, :index))
  end

  # More used privs
  defp preloaded_user(conn) do
    conn
    |> current_user()
    |> Repo.preload([cart: [:products]])
  end

  # Get a triplet of information, probably can be overriden.
  defp get_params_and_cart_name(conn, id) do
    user_cart = get_session(conn, :user_cart_name)
    product = Accounts.get_product!(id)

    product_params = Map.take(product, [:id])

    {user_cart, product, product_params}
  end
end
