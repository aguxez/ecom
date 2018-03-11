defmodule EcomWeb.Plugs.Locale do
  @moduledoc false

  import Plug.Conn

  def init(_opts), do: nil

  def call(conn, _opts) do
    locale = conn.params["lang"] || get_session(conn, :locale)

    put_locale?(conn, locale)
  end

  defp put_locale?(conn, nil) do
    conn
  end

  defp put_locale?(conn, locale) do
    Gettext.put_locale(Gettext, locale)

    put_session(conn, :locale, locale)
  end
end
