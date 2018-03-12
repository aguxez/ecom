defmodule Ecom.Accounts.CartProductTest do
  @moduledoc false

  use Ecom.DataCase

  alias Ecom.Accounts.CartProduct

  setup do
    user = insert(:user)
    product = insert(:product, user_id: user.id)
    cart = insert(:cart, user_id: user.id)

    {:ok, user: user, product: product, cart: cart}
  end

  test "changeset is valid", %{product: product, cart: cart} do
    attrs = %{product_id: product.id, cart_id: cart.id}
    changeset = CartProduct.changeset(%CartProduct{}, attrs)

    assert changeset.valid?
  end

  test "changeset is invalid", %{product: product} do
    changeset = CartProduct.changeset(%CartProduct{}, %{product_id: product.id})

    refute changeset.valid?
  end
end
