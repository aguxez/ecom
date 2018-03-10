defmodule Ecom.Interfaces.Worker do
  @moduledoc false

  alias Ecom.Worker

  defdelegate update_user(user, params_password, attrs, atom), to: Worker
  defdelegate create_product(user, params), to: Worker
  defdelegate sign_in(user, password), to: Worker
  defdelegate new_user(params), to: Worker
  defdelegate empty_user_cart(user, proc_id, param_proc_id), to: Worker
  defdelegate after_payment(user, proc_id, param), to: Worker
  defdelegate zip_from(products, id), to: Worker
  defdelegate address_has_nil_field(user), to: Worker
end
