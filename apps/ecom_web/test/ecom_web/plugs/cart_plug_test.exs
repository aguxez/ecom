defmodule EcomWeb.Plugs.CartPlugTest do
  @moduledoc false

  use EcomWeb.ConnCase

  import Plug.Test

  test ":user_cart is put on session if it doesn't exist", %{conn: conn} do
    conn = get(conn, "/")

    assert get_session(conn, :user_cart) == %{}
  end

  test ":user_cart isn't put if it already exists", %{conn: conn} do
    conn = init_test_session(conn, user_cart: %{12 => %{id: 12, value: 2}})

    refute get_session(conn, :user_cart) == %{}
  end
end
