defmodule EcomWeb.PubCategoryController do
  @moduledoc false

  use EcomWeb, :controller

  alias Ecom.Interfaces.Accounts

  def index(conn, _params) do
    products = Accounts.list_products()

    render(conn, "index.html", products: products)
  end
end
