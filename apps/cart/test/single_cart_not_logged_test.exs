defmodule Cart.SingleCartNotLoggedTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Cart.SingleCart
  alias Cart.Sup.SingleCartSup

  # Since tests are for each app, we're going to the GenServer directly
  setup_all do
    SingleCartSup.start_child("cart1")
    SingleCartSup.start_child("cart2")

    :ok
  end

  test "Can't create cart with same name" do
    assert {:error, {:already_started, _pid}} = SingleCartSup.start_child("cart1")
    assert {:error, {:already_started, _pid}} = SingleCartSup.start_child("cart2")
  end

  test "Adds product to cart" do
    assert :added == SingleCart.add_to_cart("cart1", %{"name" => "some product"}, [logged: false])
    assert :already_added == SingleCart.add_to_cart("cart1", %{"name" => "some product"}, [logged: false])
  end

  test "shows cart state" do
    assert [] == SingleCart.show_cart("cart2", [logged: false])

    # Add a product and change state
    assert :added == SingleCart.add_to_cart("cart2", %{"name" => "A product"}, [logged: false])
    assert [%{"name" => "A product"}] == SingleCart.show_cart("cart2", [logged: false])
  end

  test "removes product from state" do
    assert [%{"name" => "A product"}] == SingleCart.show_cart("cart2", [logged: false])
    assert :removed == SingleCart.remove_from_cart("cart2", %{"name" => "A product"}, [logged: false])
    assert [] == SingleCart.show_cart("cart2", [logged: false])
  end
end
