defmodule Ecom.CartTaskTest do
  @moduledoc false

  use Ecom.DataCase

  alias Ecom.{CartTask, Repo, ProductValues, Accounts}

  setup do
    user = insert(:user)
    product = insert(:product, user_id: user.id)
    cart = insert(:cart, user_id: user.id)
    user = Repo.preload(user, cart: [:products])

    ProductValues.start_link(user.id)

    {:ok, user: user, product: product, cart: cart}
  end

  # Varios of CartTask functions get a 'conn' as an argument but since we don't touch the
  # 'conn' but to send it back to the controller, we can use any value for tests

  test "adds product to db", %{user: user, product: product} do
    {_attrs, action, _} = add_and_retrieve_user(user, product)

    assert {%{}, :added} = action
  end

  test "can't add a product that it's already added", %{user: user, product: product} do
    {attrs, _, new_user} = add_and_retrieve_user(user, product)

    action = CartTask.add_to_db_cart(%{}, new_user, [attrs])

    assert {%{}, :already_added} = action
  end

  test "deletes db product", %{user: user, product: product} do
    {_attrs, _, new_user} = add_and_retrieve_user(user, product)
    action = CartTask.delete_db_cart_product(%{}, new_user, %{id: product.id})

    assert {%{}, :removed} = action
  end

  test "updates values of cart items", %{user: user, product: product} do
    {_, _, new_user} = add_and_retrieve_user(user, product)
    attrs = %{"#{product.id}" => "12"}
    action = CartTask.db_update_cart_values(%{}, new_user, attrs)
    values = ProductValues.get_all_values(new_user.id)

    assert {:ok, %{}} = action
    assert %{product.id => %{value: 12}} == values
  end

  defp add_and_retrieve_user(user, product) do
    attrs = %{id: product.id, value: "12"}

    action = CartTask.add_to_db_cart(%{}, user, [attrs])

    new_user =
      user.id
      |> Accounts.get_user!()
      |> Repo.preload(cart: [:products])

    {attrs, action, new_user}
  end
end
