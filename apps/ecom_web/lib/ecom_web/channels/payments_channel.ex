defmodule EcomWeb.PaymentsChannel do
  @moduledoc false

  use Phoenix.Channel

  def join("payments:" <> token, _, socket) do
    %{id: id} = socket.assigns[:user]

    with {:ok, user_id} <- Phoenix.Token.verify(socket, "user auth", token, max_age: 1_209_600),
         true <- id == user_id || Application.get_env(:ecom_web, :env) == :dev do

        {:ok, socket}
    else
      {:error, _} -> :error
      false -> {:error, "Wrong channel"}
    end
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
