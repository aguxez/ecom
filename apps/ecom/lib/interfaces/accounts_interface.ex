defmodule Ecom.Interfaces.AccountsInterface do
  @moduledoc false

  alias Ecom.Accounts

  defdelegate create_cart(attrs),         to: Accounts
  defdelegate update_cart(cart, attrs),   to: Accounts
  defdelegate create_user(attrs),         to: Accounts
  defdelegate create_product(attrs),      to: Accounts
end
