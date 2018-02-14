defmodule Cart.SingleCart do
  @moduledoc """
  GenServer in charge of keeping state of each user's cart.
  """

  use GenServer

  alias Cart.SingleCartReg

  # API
  def start_link(name) do
    GenServer.start_link(__MODULE__, [], name: via_tuple(name))
  end

  def add_to_cart(name, product) do
    GenServer.call(via_tuple(name), {:add_to_cart, product})
  end

  def show_cart(name) do
    GenServer.call(via_tuple(name), :show)
  end

  def remove_from_cart(name, product) do
    GenServer.cast(via_tuple(name), {:remove, product})
  end

  # priv
  defp via_tuple(name) do
    {:via, Registry, {SingleCartReg, name}}
  end

  # Server
  def init(state) do
    {:ok, state}
  end

  def handle_call({:add_to_cart, product}, _from, state) do
    if Enum.member?(state, product) do
      {:reply, :already_added, state}
    else
      new_state = List.insert_at(state, -1, product)
      {:reply, :added, new_state}
    end
  end

  def handle_call(:show, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:remove, product}, state) do
    new_state = Enum.reject(state, &(&1 == product))

    {:noreply, new_state}
  end
end
