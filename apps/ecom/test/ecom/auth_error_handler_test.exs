defmodule Ecom.AuthErrorHandlerTest do
  @moduledoc false

  use EcomWeb.ConnCase

  alias Ecom.AuthErrorHandler

  describe("auth_error") do
    setup do
      {:ok, conn: build_conn()}
    end

    test "sends 401 resp with {message: <type>} json as body", %{conn: conn} do
      conn = AuthErrorHandler.auth_error(conn, {:unauthorized, nil}, nil)

      assert conn.status == 401
      assert conn.resp_body == Poison.encode!(%{message: "unauthorized"})
    end
  end
end
