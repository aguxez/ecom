defmodule EcomWeb.PaymentsControllerTest do
  @moduledoc false

  use EcomWeb.ConnCase

  # TODO: RE-do payments tests

  setup do
    bypass = Bypass.open()
    user = insert(:user)

    {:ok, bypass: bypass, user: user}
  end

  defp sign_in(conn, user) do
    EcomWeb.Auth.Guardian.Plug.sign_in(conn, user)
  end

  defp conn_url(port), do: "http://localhost:#{port}/payments"
end
