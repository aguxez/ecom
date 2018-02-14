defmodule Cart.Sup.SingleCartSup do
  @moduledoc """
  SingleCart's supervisor.
  """

  use DynamicSupervisor

  alias Cart.SingleCart

  def start_link(arg) do
    DynamicSupervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def start_child(name) do
    spec = Supervisor.Spec.worker(SingleCart, [name])
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  def init(_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
