defmodule Ecom.Payments.MercadoPago do
  @moduledoc false

  alias Ecom.Payments.MockPayment

  def send_items(items) do
    case Application.get_env(:ecom, :env) do
      :test -> MockPayment.send_items(items)
      _ -> normal_req(items)
    end
  end

  defp normal_req(items) do
    req_items = Poison.encode!(items)

    %HTTPoison.Response{body: body} =
      HTTPoison.post!(endpoint(), req_items, [{"Content-Type", "application/json"}])

    body
    |> Poison.decode!()
    |> evaluate_response()
  end

  defp endpoint, do: Application.get_env(:ecom, :mercado_pago_url)

  defp evaluate_response(%{"live" => _live_url, "sandbox" => sandbox}) do
    {:ok, sandbox}
  end

  defp evaluate_response(%{"error" => reason}) do
    {:error, reason}
  end
end
