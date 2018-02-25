defmodule Ecom.Payments.Processor do
  @moduledoc false

  # TODO: Test module, change implementation

  alias Gringotts.Gateways.Stripe

  def create_purchase(params, processor) do
    case Application.get_env(:ecom, :env) do
      :test -> mock_payment(params, processor)
      _     -> make_payment(params, processor)
    end
  end

  defp mock_payment(token, :stripe) do
    # This time we use the "token" as the URL because we're not actually hitting Stripe's API.
    token
    |> HTTPoison.post([])
    |> process_response()
  end

  defp process_response({:ok, %{status_code: 200}}), do: {:ok, :accepted}
  defp process_response({:ok, %{status_code: body}}), do: {:error, {:failed, body}}

  defp make_payment(token, :stripe) do
    payment = Gringotts.purchase(Stripe, 50, %{}, source: token)

    cond do
      payment["status"] == "succeeded" -> {:ok, :accepted}
      payment["status"] == "failed"    -> {:error, {:failed, payment}}
      payment["error"] -> {:error, {:req_error, payment}}
    end
  end
end
