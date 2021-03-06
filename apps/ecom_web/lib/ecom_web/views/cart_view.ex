defmodule EcomWeb.CartView do
  @moduledoc false

  use EcomWeb, :view

  alias Ecom.Interfaces.Accounts

  def product_quantity(id) do
    product = Accounts.get_product!(id)
    product.quantity
  end

  def title("index.html", _assigns), do: "Your cart | Ecom"
end
