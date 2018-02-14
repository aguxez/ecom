defmodule Cart.Interfaces.SingleCart do
  @moduledoc false

  alias Cart.SingleCart

  defdelegate add_to_cart(name, product),   to: SingleCart
  defdelegate show_cart(name),              to: SingleCart
end
