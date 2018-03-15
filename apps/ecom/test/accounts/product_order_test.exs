defmodule Ecom.Accounts.ProductOrderTest do
  @moduledoc false

  use Ecom.DataCase

  alias Ecom.Accounts.ProductOrder

  setup do
    user = insert(:user)
    product = insert(:product, user_id: user.id)
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

  test "product_order returns correct fields", %{product_order: p_order} do
    assert p_order.values == [%{"2" => 12}]
    assert p_order.completed == false
  end
end
