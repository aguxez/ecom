defmodule Cart.SingleCartTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Cart.SingleCart
  alias Cart.Sup.SingleCartSup

  # Since tests are for each app, we're going to the GenServer directly
  setup_all do
    SingleCartSup.start_child("some name")
    SingleCartSup.start_child("some other name")

    :ok
  end

  test "Can't create cart with same name" do
    assert {:error, {:already_started, _pid}} = SingleCartSup.start_child("some name")
    assert {:error, {:already_started, _pid}} = SingleCartSup.start_child("some other name")
  end

  test "Adds product to cart" do
    assert :added == SingleCart.add_to_cart("some name", %{name: "some product"})
    assert :already_added == SingleCart.add_to_cart("some name", %{name: "some product"})
  end

  test "shows cart state" do
    assert [] == SingleCart.show_cart("some other name")

    # Add a product and change state
    assert :added == SingleCart.add_to_cart("some other name", %{name: "A product"})
    assert [%{name: "A product"}] == SingleCart.show_cart("some other name")
  end

  test "removes product from state" do
    SingleCart.add_to_cart("some name", %{name: "some product"})

    assert [%{name: "some product"}] == SingleCart.show_cart("some name")
    assert :ok == SingleCart.remove_from_cart("some name", %{name: "some product"})
    assert [] == SingleCart.show_cart("some name")
  end
end
