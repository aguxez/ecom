defmodule EcomWeb.Helpers do
  @moduledoc false

  import Plug.Conn

  alias Ecom.{Accounts, Repo}
  alias Ecom.Interfaces.{ProductValues}

  def current_user(conn) do
    user = EcomWeb.Auth.Guardian.Plug.current_resource(conn)

    unless user == nil, do: user
  end

  # Define 'fields' to get from 'user'
  def current_user(conn, fields) do
    user = EcomWeb.Auth.Guardian.Plug.current_resource(conn)

    unless user == nil, do: Map.take(user, fields)
  end

  def get_csrf_token do
    Plug.CSRFProtection.get_csrf_token()
  end

  # removes item from session and puts them in the db cart
  def sign_in_and_remove(conn, user, session_cart) do
    user = Repo.preload(user, cart: [:products])

    # Leaves out items already on user's cart
    remove_from_session(session_cart, user.cart.products, user)

    put_session(conn, :user_cart, %{})
  end

  defp remove_from_session(cart, user_products, user) do
    Enum.map(cart, fn {key, val} -> evaluate_product({key, val}, user_products, user) end)
  end

  defp evaluate_product({key, value}, user_products, user) do
    ids = Enum.map(user_products, & &1.id)

    if key not in ids, do: add_product_to_user(user, {key, value})
  end

  defp add_product_to_user(user, {id, value}) do
    cart_id = user.cart.id
    Accounts.create_cart_product(%{cart_id: cart_id, product_id: id})
    ProductValues.save_value_for(user.id, value)
  end
end
