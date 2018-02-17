defmodule Cart.SingleCart do
  @moduledoc """
  GenServer in charge of keeping state of each user's cart.

  This module has two responsabilities, saving the cart in memory while the user
  is not logged, once the user is logged in, the cart is appended to the array of products
  and the state is deleted.
  """

  use GenServer

  alias Cart.SingleCartReg
  alias Ecom.Interfaces.AccountsInterface

  # API
  def start_link(name) do
    GenServer.start_link(__MODULE__, [], name: via_tuple(name))
  end

  def add_to_cart(name, product, opt) do
    GenServer.call(via_tuple(name), {:add_to_cart, product, opt})
  end

  def show_cart(name, opt) do
    GenServer.call(via_tuple(name), {:show, opt})
  end

  def remove_from_cart(name, product, opt) do
    GenServer.call(via_tuple(name), {:remove, product, opt})
  end

  # priv
  defp via_tuple(name) do
    {:via, Registry, {SingleCartReg, name}}
  end

  # Server
  def init(state) do
    {:ok, state}
  end

  def handle_call({:add_to_cart, product, [logged: true, user: user]}, _from, state) do
    cart_products = user.cart.products
    attrs = %{products: cart_products ++ [product]}

    action =
      with false <- Enum.member?(cart_products, product),
      {:ok, _} <- AccountsInterface.update_cart(user.cart, attrs) do

        :added
      else
        true ->
          :already_added
          {:error, _} ->
            :error
          end

    {:reply, action, state}
  end

  def handle_call({:add_to_cart, product, [logged: false]}, _from, state) do
    {action, new_state} =
      if Enum.member?(state, product) do
        {:already_added, state}
      else
        new_state = List.insert_at(state, -1, product)

        {:added, new_state}
      end

    {:reply, action, new_state}
  end

  def handle_call({:show, [logged: true, user: user]}, _from, state) do
    {:reply, user.cart.products, state}
  end

  def handle_call({:show, [logged: false]}, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:remove, product, [logged: true, user: user]}, _from, state) do
    attrs = Enum.reject(user.cart.products, &(&1 == product))

    action =
      case AccountsInterface.update_cart(user.cart, %{products: attrs}) do
        {:ok, _} -> :removed
        {:error, _} -> :failed
      end

    {:reply, action, state}
  end

  def handle_call({:remove, product, [logged: false]}, _from, state) do
    new_state = Enum.reject(state, &(&1 == product))

    {:reply, new_state, state}
  end
end
