defmodule Cart.Interfaces.SingleCart do
  @moduledoc false

  alias Cart.SingleCart

  defdelegate add_to_cart(name, product, opt),       to: SingleCart
  defdelegate show_cart(name, opt),                  to: SingleCart
  defdelegate remove_from_cart(name, product, opt),  to: SingleCart
  defdelegate sign_in_and_remove(conn, name, opt),   to: SingleCart
end
