defmodule Ecom.Accounts.CartTest do
  @moduledoc false

  use Ecom.DataCase

  alias Ecom.Accounts.Cart

  setup do
    user = insert(:user)

    {:ok, user: user}
  end

  test "changeset valid", %{user: user} do
    changeset = Cart.changeset(%Cart{}, %{user_id: user.id})

    assert changeset.valid?
  end

  test "changeset is invalid" do
    changeset = Cart.changeset(%Cart{}, %{some: :param})

    refute changeset.valid?
  end
end
