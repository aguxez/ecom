defmodule Ecom.Payments.MockPayment do
  @moduledoc false

  # For testing
  def pay(%{token: token}, :stripe) do
    # This time we use the "token" as the URL because we're not actually hitting Stripe's API.
    token
    |> HTTPoison.post([])
    |> process_response()
  end

  defp process_response({:ok, %{status_code: 200}}), do: {:ok, :accepted}
  defp process_response({:ok, %{status_code: body}}), do: {:error, {:failed, body}}
end
