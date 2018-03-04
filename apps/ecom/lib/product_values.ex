defmodule Ecom.ProductValues do
  @moduledoc false

  use Agent

  def start_link(id) do
    Agent.start_link(fn -> %{} end, name: via_tuple(id))
  end

  def save_value_for(id, %{} = product) do
    Agent.update(via_tuple(id), fn x -> Map.put(x, product["id"], %{"value" => product["value"]}) end)
  end

  def get_all_values(id) do
    Agent.get(via_tuple(id), &(&1))
  end

  def remove_from(id, product_id) do
    Agent.update(via_tuple(id), fn x -> Map.delete(x, product_id) end)
  end

  defp via_tuple(name) do
    {:via, Registry, {:product_values, name}}
  end
end
