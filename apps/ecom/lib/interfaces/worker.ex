defmodule Ecom.Interfaces.Worker do
  @moduledoc false

  alias Ecom.Worker

  defdelegate update_user(user, params_password, attrs),      to: Worker
  defdelegate can_create_product?(user, params),              to: Worker
  defdelegate sign_in(user, password),                        to: Worker
  defdelegate new_user(params),                               to: Worker
  defdelegate empty_user_cart(user, proc_id, param_proc_id),  to: Worker
end
