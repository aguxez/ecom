defmodule Ecom.Accounts.ProductOrdersTest do
  @moduledoc false

  use Ecom.DataCase

  alias Ecom.Accounts.ProductOrders

  setup do
    user = insert(:user)
    product = insert(:product, user_id: user.id)
    order = insert(:order, user_id: user.id)

    {:ok, product: product, order: order}
  end

  test "changeset is valid", %{product: product, order: order} do
    changeset =
      ProductOrders.changeset(%ProductOrders{}, %{product_id: product.id, order_id: order.id})

    assert changeset.valid?
  end

  test "changeset is invalid", %{order: order} do
    changeset = ProductOrders.changeset(%ProductOrders{}, %{order_id: order.id})

    refute changeset.valid?
  end
end
