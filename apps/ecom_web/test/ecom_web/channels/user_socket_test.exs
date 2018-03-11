defmodule EcomWeb.Channels.UserSocketTest do
  @moduledoc false

  use EcomWeb.ChannelCase

  alias EcomWeb.{UserSocket, PaymentsChannel}

  setup do
    user = insert(:user)
    token = Phoenix.Token.sign(EcomWeb.Endpoint, "some_salt", user.id)

    {:ok, _, socket} =
      ""
      |> socket(%{user: user})
      |> subscribe_and_join(PaymentsChannel, "payments:#{token}")

    {:ok, socket: socket, token: token}
  end

  test "connects with valid token for user", %{socket: socket, token: token} do
    ref = UserSocket.connect(%{"token" => token}, socket)

    assert {:ok, _} = ref
  end

  test "returns :error if token is invalid", %{socket: socket} do
    ref = UserSocket.connect(%{"token" => "123"}, socket)

    assert :error = ref
  end
end
