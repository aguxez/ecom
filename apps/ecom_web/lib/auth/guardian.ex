defmodule EcomWeb.Auth.Guardian do
  @moduledoc false

  use Guardian, otp_app: :ecom_web

  alias Ecom.Accounts
  alias Ecom.Accounts.User

  def subject_for_token(%User{} = user, _claims) do
    {:ok, "User:#{user.id}"}
  end

  def subject_for_token(_, _) do
    {:error, :unknown_resource}
  end

  def resource_from_claims(%{"sub" => "User:" <> id}) do
    case Integer.parse(id) do
      {uid, ""} -> {:ok, Accounts.get_user!(uid)}
      _         -> {:error, :invalid_id}
    end
  rescue
    Ecto.NoResultsError -> {:error, :no_result}
  end

  def resource_from_claims(_) do
    {:error, :invalid_claims}
  end
end
