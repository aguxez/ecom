defmodule Ecom.ProductValuesTest do
  @moduledoc false

  use Ecom.DataCase

  alias Ecom.ProductValues

  setup do
    user =
      :user
      |> insert()
      |> Repo.preload(cart: [:products], products: [])

    insert(:cart, user_id: user.id)
    ProductValues.start_link(user.id)

    {:ok, user: user}
  end

  test "returns {:error, {:already_started, <PID>}}", %{user: user} do
    assert {:error, {:already_started, pid}} = ProductValues.start_link(user.id)
    assert is_pid(pid)
  end

  test "saves and retrieves value", %{user: user} do
    attrs = %{id: 12, value: 2}
    ProductValues.save_value_for(user.id, attrs)

    assert %{12 => %{value: 2}} == ProductValues.get_all_values(user.id)
  end

  test "removes value from state", %{user: user} do
    ProductValues.remove_from(user.id, 12)

    assert %{} == ProductValues.get_all_values(user.id)
  end
end
