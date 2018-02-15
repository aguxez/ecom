defmodule Cart.Interfaces.SingleCart do
  @moduledoc false

  alias Cart.SingleCart

  defdelegate add_to_cart(name, product),       to: SingleCart
  defdelegate show_cart(name),                  to: SingleCart
  defdelegate remove_from_cart(name, product),  to: SingleCart
end
