defmodule Ecom.Interfaces.Accounts do
  @moduledoc false

  alias Ecom.Accounts

  defdelegate change_user(user),                         to: Accounts
  defdelegate list_products,                             to: Accounts
  defdelegate list_users,                                to: Accounts
  defdelegate change_product(product),                   to: Accounts
  defdelegate create_product(params),                    to: Accounts
  defdelegate create_cart(params),                       to: Accounts
  defdelegate create_user(params),                       to: Accounts
  defdelegate get_product!(id),                          to: Accounts
  defdelegate update_product(product, product_params),   to: Accounts
  defdelegate delete_product(id),                        to: Accounts
end
