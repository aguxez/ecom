defmodule Ecom.Accounts.ProductOrder do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias Ecom.Accounts.{Product, Order, ProductOrder}

  schema "product_orders" do
    belongs_to(:product, Product)
    belongs_to(:order, Order)

    timestamps()
  end

  def changeset(%ProductOrder{} = product_orders, attrs) do
    product_orders
    |> cast(attrs, [:product_id, :order_id])
    |> foreign_key_constraint(:product_id)
    |> foreign_key_constraint(:order_id)
    |> validate_required([:product_id, :order_id])
  end
end
