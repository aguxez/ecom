defmodule Ecom.Accounts.OrderTest do
  @moduledoc false

  use Ecom.DataCase

  alias Ecom.Accounts.Order

  setup do
    user = insert(:user)

    {:ok, user: user}
  end

  test "changeset is valid", %{user: user} do
    changeset = Order.changeset(%Order{}, %{user_id: user.id})

    assert changeset.valid?
  end

  test "changeset is invalid" do
    changeset = Order.changeset(%Order{}, %{})

    refute changeset.valid?
  end
end
