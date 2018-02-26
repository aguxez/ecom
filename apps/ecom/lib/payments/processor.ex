defmodule Ecom.Payments.Processor do
  @moduledoc false

  # TODO: Test module, change implementation

  alias Ecom.Payments.MockPayment
  alias Gringotts.Gateways.Stripe

  def create_purchase(params, processor) do
    case Application.get_env(:ecom, :env) do
      :test -> MockPayment.pay(params, processor)
      _     -> make_payment(params, processor)
    end
  end

  # Real Payment
  defp make_payment(%{token: token, total: total}, :stripe) do
    payment = Gringotts.purchase(Stripe, total, %{}, source: token)

    cond do
      payment["status"] == "succeeded" -> {:ok, :accepted}
      payment["status"] == "failed"    -> {:error, {:failed, payment}}
      payment["error"] -> {:error, {:req_error, payment}}
    end
  end
end
