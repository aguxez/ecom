defmodule EcomWeb.Channels.PaymentsChannelTest do
  @moduledoc false

  use EcomWeb.ChannelCase

  alias EcomWeb.PaymentsChannel
  alias Ecom.ProductValues

  setup do
    user = insert(:user)
    product = insert(:product, user_id: user.id)
    cart = insert(:cart, user_id: user.id)
    token = Phoenix.Token.sign(EcomWeb.Endpoint, "some_salt", user.id)

    insert(:cart_products, cart_id: cart.id, product_id: product.id)

    ProductValues.start_link(user.id)

    {:ok, _, socket} =
      ""
      |> socket(%{user: user})
      |> subscribe_and_join(PaymentsChannel, "payments:#{token}")

    {:ok, socket: socket}
  end

  test "user joins payments channel", %{socket: socket} do
    push(socket, "form_submit", %{"form" => %{}})

    assert_broadcast("form_resubmit", %{form: _})
  end
end
