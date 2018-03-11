defmodule EcomWeb.Plugs.Locale do
  @moduledoc false

  import Plug.Conn

  def init(_opts), do: nil

  def call(conn, _opts) do
    conn
    |> get_session(:locale)
    |> put_locale?(conn)
  end

  defp put_locale?(nil, conn) do
    conn
  end

  defp put_locale?(locale, conn) do
    Gettext.put_locale(Gettext, locale)

    put_session(conn, :locale, locale)
  end
end
