defmodule EcomWeb.Plugs.VerifyParams do
  @moduledoc false

  # This module added everything we needed here.
  use EcomWeb, :controller

  def init(opts), do: opts

  def call(conn, opts) do
    conn
    |> query_params()
    |> contains_field(opts)
    |> handle_response(conn)
  end

  defp query_params(conn) do
    conn
    |> fetch_query_params()
    |> Map.get(:query_params)
    |> Map.keys()
  end

  defp contains_field(keys, fields) do
    Enum.all?(fields, & &1 in keys)
  end

  defp handle_response(false, conn) do
    conn
    |> put_flash(:alert, gettext("We couldn't find an ID to associate with your session"))
    |> redirect(to: page_path(conn, :index))
    |> halt()
  end

  defp handle_response(true, conn) do
    conn
  end
end
