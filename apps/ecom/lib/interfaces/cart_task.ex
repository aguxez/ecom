defmodule Ecom.Interfaces.CartTask do
  @moduledoc false

  alias Ecom.CartTask

  defdelegate add_to_db_cart(conn, user, product),                   to: CartTask
  defdelegate delete_db_cart_product(conn, user, product),           to: CartTask
  defdelegate db_update_cart_values(conn, user, products),           to: CartTask
end
