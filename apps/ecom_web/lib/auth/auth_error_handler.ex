defmodule EcomWeb.Auth.AuthErrorHandler do
  @moduledoc false

  use EcomWeb, :controller

  def auth_error(conn, {_type, _reason}, _opts) do
    conn
    |> put_flash(:alert, gettext("Please login first"))
    |> redirect(to: session_path(conn, :new))
  end
end
