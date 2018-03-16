defmodule EcomWeb.OrdersView do
  @moduledoc false

  use EcomWeb, :view

  def value_for(id, [values]) do
    Map.get(values, to_string(id))
  end
end
