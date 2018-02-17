defmodule Ecom.Interfaces.AccountsInterface do
  @moduledoc false

  defdelegate update_cart(cart, attrs),     to: Ecom.Accounts
end
