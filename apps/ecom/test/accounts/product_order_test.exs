defmodule Ecom.Accounts.ProductOrderTest do
  @moduledoc false

  use Ecom.DataCase

  alias Ecom.Accounts.ProductOrder

  setup do
    user = insert(:user)
    category = insert(:category)
    product = insert(:product, user_id: user.id, category_id: category.id)
    order = insert(:order, user_id: user.id)
    product_order = insert(:product_order, product_id: product.id, order_id: order.id)

    {:ok, product: product, order: order, product_order: product_order}
  end

  test "changeset is valid", %{product: product, order: order} do
    changeset =
      ProductOrder.changeset(%ProductOrder{}, %{product_id: product.id, order_id: order.id})

    assert changeset.valid?
  end

  test "changeset is invalid", %{order: order} do
    changeset = ProductOrder.changeset(%ProductOrder{}, %{order_id: order.id})

    refute changeset.valid?
  end
end
