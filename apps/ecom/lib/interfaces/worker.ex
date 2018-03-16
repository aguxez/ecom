defmodule Ecom.Interfaces.Worker do
  @moduledoc false

  alias Ecom.Worker

  defdelegate update_user(user, params_password, attrs, atom), to: Worker
  defdelegate create_product(user, params), to: Worker
  defdelegate sign_in(user, password), to: Worker
  defdelegate new_user(params), to: Worker
  defdelegate after_payment(user, proc_id, param), to: Worker
  defdelegate zip_from(products, id), to: Worker
  defdelegate address_has_nil_field(user), to: Worker
  defdelegate update_product(product, params), to: Worker
  defdelegate delete_product(product), to: Worker
  defdelegate mass_update_orders(data), to: Worker
  defdelegate orders_query(status), to: Worker
end
