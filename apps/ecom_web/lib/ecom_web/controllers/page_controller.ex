defmodule EcomWeb.PageController do
  @moduledoc false

  use EcomWeb, :controller

  alias Ecom.Interfaces.Accounts

  action_fallback EcomWeb.FallbackController

  def index(conn, _params) do
    products = Accounts.list_products()

    render(conn, "index.html", products: products)
  end
end
