defmodule EcomWeb.FallbackController do
  @moduledoc false

  use EcomWeb, :controller

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_flash(:alert, gettext("Not authorized"))
    |> redirect(to: page_path(conn, :index))
  end
end
