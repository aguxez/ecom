defmodule Ecom.Payments.Processor do
  @moduledoc false

  # TODO: Test module, change implementation

  alias Ecom.Payments.MockPayment
  alias Gringotts.Gateways.Stripe

  def create_purchase(params, processor) do
    case Application.get_env(:ecom, :env) do
      :test -> MockPayment.pay(params, processor)
      _ -> make_payment(params, processor)
    end
  end

  # Real Payment
  defp make_payment(_params, :paypal) do
    :ok
  end
end
