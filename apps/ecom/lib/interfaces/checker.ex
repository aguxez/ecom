defmodule Ecom.Interfaces.Checker do
  @moduledoc false

  alias Ecom.Checker

  defdelegate update_user(user, params_password, attrs),   to: Checker
  defdelegate can_create_product?(user, params),           to: Checker
  defdelegate sign_in(user, password),                     to: Checker
  defdelegate new_user(params),                            to: Checker
end
