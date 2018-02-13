defmodule EcomWeb.PublicProductController do
  @moduledoc false

  use EcomWeb, :controller

  alias Ecom.Accounts
  alias EcomWeb.ErrorView

  def show(conn, %{"id" => id}) do
    product = Accounts.get_product!(id)

    render(conn, "show.html", product: product)
  rescue
    Ecto.NoResultsError ->
      conn
      |> render(ErrorView, "404.html")
  end
end
