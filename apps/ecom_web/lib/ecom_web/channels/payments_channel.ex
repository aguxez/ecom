defmodule EcomWeb.PaymentsChannel do
  @moduledoc false

  use Phoenix.Channel

  alias Ecom.Repo
  alias Ecom.Interfaces.Worker

  def join("payments:" <> token, _, socket) do
    %{id: id} = socket.assigns[:user]

    with {:ok, user_id} <- Phoenix.Token.verify(EcomWeb.Endpoint, "some_salt", token, max_age: 1_209_600),
         true <- id == user_id || Application.get_env(:ecom_web, :env) == :dev do
      {:ok, socket}
    else
      {:error, _} -> :error
      false -> {:error, "Wrong channel"}
    end
  end

  def handle_in("form_submit", %{"form" => _data}, socket) do
    total = get_product_total(socket.assigns)
    business_id = Application.get_env(:ecom_web, :paypal_business_id)

    attr = %{
      "first" => %{"name" => "amount", "value" => total},
      "second" => %{"name" => "business", "value" => business_id}
    }

    broadcast!(socket, "form_resubmit", %{form: attr})

    {:noreply, socket}
  end

  defp get_product_total(%{user: user}) do
    user = Repo.preload(user, cart: [:products])

    user.cart.products
    |> Worker.zip_from(user.id)
    |> Enum.map(fn {product, value} -> product.price * value end)
    |> Enum.sum()
  end
end
