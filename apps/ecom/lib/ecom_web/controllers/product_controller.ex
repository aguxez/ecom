defmodule EcomWeb.ProductController do
  @moduledoc false

  use EcomWeb, :controller

  alias Ecom.Accounts.{Product}
  alias Ecom.Accounts

  plug :scrub_params, "product" when action in [:create]

  plug Bodyguard.Plug.Authorize,
    policy: Product,
    action: :create_products,
    user: &Guardian.Plug.current_resource/1,
    fallback: EcomWeb.FallbackController

  def new(conn, _params) do
    changeset = Product.changeset(%Product{}, %{})

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"product" => product_params}) do
    user = current_user(conn, [:id])
    params = Map.merge(product_params, %{"user_id" => user.id})

    case Accounts.create_product(params) do
      {:ok, %Product{}} ->
        conn
        |> put_flash(:success, gettext("Product created successfully"))
        |> redirect(to: page_path(conn, :index))
      {:error, changeset} ->
        conn
        |> put_flash(:alert, gettext("There was a problem trying to add your product"))
        |> render("new.html", changeset: changeset)
    end
  end
end
