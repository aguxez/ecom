defmodule EcomWeb.Plugs.Locale do
  @moduledoc false

  import Plug.Conn

  def init(_opts), do: nil

  def call(conn, _opts) do
    case conn.params["lang"] || get_session(conn, :locale) do
      nil     ->
        conn
      locale  ->
        Gettext.put_locale(Gettext, locale)

        put_session(conn, :locale, locale)
    end
  end
end
