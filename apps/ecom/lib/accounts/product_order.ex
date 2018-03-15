defmodule Ecom.Accounts.ProductOrder do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias Ecom.Accounts.{Product, Order, ProductOrder}

  schema "product_orders" do
    field :completed, :boolean, default: false
    field :values, {:array, :map}, default: []

    belongs_to(:product, Product)
    belongs_to(:order, Order)

    timestamps()
  end

  def changeset(%ProductOrder{} = product_orders, attrs) do
    product_orders
    |> cast(attrs, ~w(product_id order_id completed values)a)
    |> foreign_key_constraint(:product_id)
    |> foreign_key_constraint(:order_id)
    |> validate_required(~w(product_id order_id)a)
  end
end
