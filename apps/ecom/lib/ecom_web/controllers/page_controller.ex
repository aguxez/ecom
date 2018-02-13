defmodule EcomWeb.PageController do
  @moduledoc false

  use EcomWeb, :controller

  action_fallback EcomWeb.FallbackController

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
