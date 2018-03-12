defmodule EcomWeb.Channels.UserSocketTest do
  @moduledoc false

  use EcomWeb.ChannelCase

  alias EcomWeb.{UserSocket}

  setup do
    user = insert(:user)
    token = Phoenix.Token.sign(EcomWeb.Endpoint, "token_salt", user.id)
    socket = socket("", %{user: user})

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
