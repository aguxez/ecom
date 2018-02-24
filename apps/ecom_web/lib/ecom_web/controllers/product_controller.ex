defmodule EcomWeb.ProductController do
  @moduledoc false

  use EcomWeb, :controller

  alias Ecom.Interfaces.Accounts
  alias EcomWeb.ErrorView

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def show(conn, %{"id" => id}) do
    product = Accounts.get_product!(id)

    render(conn, "show.html", product: product)
  rescue
    Ecto.NoResultsError ->
      conn
      |> render(ErrorView, "404.html")
  end
end
