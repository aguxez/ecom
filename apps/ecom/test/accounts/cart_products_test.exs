defmodule Ecom.Accounts.CartProductsTest do
  @moduledoc false

  use Ecom.DataCase

  alias Ecom.Accounts.CartProducts

  setup do
    user = insert(:user)
    product = insert(:product, user_id: user.id)
    cart = insert(:cart, user_id: user.id)

    {:ok, user: user, product: product, cart: cart}
  end

  test "changeset is valid", %{product: product, cart: cart} do
    attrs = %{product_id: product.id, cart_id: cart.id}
    changeset = CartProducts.changeset(%CartProducts{}, attrs)

    assert %Ecto.Changeset{valid?: true} = changeset
  end
end
