defmodule Cart.SingleCart do
  @moduledoc """
  GenServer in charge of keeping state of each user's cart.

  This module has two responsabilities, saving the cart in memory while the user
  is not logged, once the user is logged in, the cart is appended to the array of products
  and the state is deleted.
  """

  # TODO: This module has issues while inserting values, 'List.flatten' is often used...
  # TODO: Module is braking, fix.

  use GenServer

  alias Ecom.Interfaces.AccountsInterface

  # API
  def start_link do
    GenServer.start_link(__MODULE__, %{products: []}, name: __MODULE__)
  end

  def add_to_cart(user, product) do
    GenServer.call(__MODULE__, {:add_to_cart, user, product})
  end

  def show_cart(user) do
    GenServer.call(__MODULE__, {:show, user})
  end

  def remove_from_cart(user, product) do
    GenServer.call(__MODULE__, {:remove, user, product})
  end

  def sign_in_and_remove(conn, user) do
    GenServer.call(__MODULE__, {:sign_in_and_remove, conn, user})
  end

  def update_value(user, key, value) do
    GenServer.call(user, {:update_value, user, key, value})
  end

  # Server
  def init(state) do
    {:ok, state}
  end

  # Action called when the user is signed in. Updates the memory state and moves the products to DB.
  # 'conn' is just so we can return something to the pipeline.
  def handle_call({:sign_in_and_remove, conn, user}, _from, state) do
    # Leave out all the items that are already on user's cart
    push_action =
      state.products
      |> Enum.map(&(unless &1 in user.cart.products, do: user.cart.products ++ [&1]))
      |> Enum.reject(&is_nil/1)
      |> List.flatten()

    action =
      case AccountsInterface.update_cart(user.cart, %{products: push_action}) do
        {:ok, _} -> conn
        {:error, _} -> conn
      end

    {:reply, action, %{products: []}}
  end

  def handle_call({:update_value, user, key, value}, _from, state) do
    flat_state = List.flatten(state.products)

    map_to_insert =
      flat_state
      # 'key' is passed as a String and "id" is an Integer
      |> Enum.find(&Map.get(&1, "id") == String.to_integer(key))
      |> Map.put("value", value)

    new_state = update_in(flat_state, [Access.all()], &Map.merge(&1, map_to_insert))

    {:reply, :updated, %{products: new_state}}
  end
end
