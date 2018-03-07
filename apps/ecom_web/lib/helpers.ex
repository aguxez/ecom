defmodule EcomWeb.Helpers do
  @moduledoc false

  import Plug.Conn

  alias Ecom.{Repo, Accounts}

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
    user_prods = user.cart.products
    # Leaves out items already on user's cart

    push_action =
      session_cart
      |> Enum.map(fn {key, val} ->
        if to_string(key) not in Map.keys(user_prods) do
          Map.merge(user_prods, %{key => val})
        end
      end)
      |> Enum.reject(&is_nil/1)
      |> List.first()

    attrs =
      case push_action do
        nil -> user.cart.products
        new_value -> new_value
      end

    Accounts.update_cart(user.cart, %{products: attrs})

    put_session(conn, :user_cart, %{})
  end
end
