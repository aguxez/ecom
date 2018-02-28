defmodule EcomWeb.PaymentsChannel do
  @moduledoc false

  use Phoenix.Channel

  def join("payments:" <> _sub_topic, _, socket) do
    {:ok, socket}
  end

  def handle_in("form_submit", %{"form" => _data}, socket) do
    total = get_product_total(socket.assigns)
    attr = %{"amount" => %{"value" => total}}

    broadcast!(socket, "form_resubmit", %{form: attr})

    {:noreply, socket}
  end

  defp get_product_total(%{user: user}) do
    products = Map.values(user.cart.products)

    products
    |> Enum.map(fn product -> product["price"] * product["value"] end)
    |> Enum.sum()
  end
end
