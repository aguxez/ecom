defmodule EcomWeb.PageController do
  @moduledoc false

  use EcomWeb, :controller

  alias Ecom.Accounts

  action_fallback EcomWeb.FallbackController

  def index(conn, _params) do
    products = Accounts.list_products()
    IO.inspect(current_user(conn, "everything"))

    render(conn, "index.html", products: products)
  end
end
