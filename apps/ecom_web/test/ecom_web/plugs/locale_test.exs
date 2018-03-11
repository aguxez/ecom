defmodule EcomWeb.Plugs.LocaleTest do
  @moduledoc false

  use EcomWeb.ConnCase

  test "locale gets put in session", %{conn: conn} do
    conn = get(conn, "/?lang=es")

    assert get_session(conn, :locale)
  end
end
