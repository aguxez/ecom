defmodule EcomWeb.AdminController do
  @moduledoc false

  use EcomWeb, :controller

  import Ecto.Query, only: [from: 2]

  alias Ecom.Accounts
  alias Ecom.Accounts.{User, Product}
  alias Ecom.Repo
  alias EcomWeb.Uploaders.Image

  action_fallback EcomWeb.FallbackController

  plug Bodyguard.Plug.Authorize,
    policy: User,
    action: :admin_panel,
    user: &Guardian.Plug.current_resource/1,
    fallback: EcomWeb.FallbackController

  def index(conn, _params) do
    users_amount = length(Accounts.list_users())
    products = Accounts.list_products()

    latest_users = Repo.all(from u in User, order_by: u.inserted_at)

    render(conn, "index.html",
      users_amount: users_amount,
      latest_users: latest_users,
      products: products
    )
  end

  # Products
  def new_product(conn, _params) do
    changeset = Accounts.change_product(%Product{})

    render(conn, "new_product.html", changeset: changeset)
  end

  def create_product(conn, %{"product" => product_params}) do
    user = current_user(conn, "everything")

    params = Map.merge(product_params, %{"user_id" => user.id})

    with :ok <- Bodyguard.permit(Product, :create_products, user),
         {:ok, %Product{} = product} <- Accounts.create_product(params) do

      conn
      |> put_flash(:success, gettext("Product created successfully"))
      |> redirect(to: product_path(conn, :show, product.id))
    else
      {:error, changeset} ->
        conn
        |> put_flash(:alert, gettext("There was a problem trying to add your product"))
        |> render("new_product.html", changeset: changeset)
    end
  end

  def delete_product(conn, %{"id" => id}) do
    product = Accounts.get_product!(id)

    case Accounts.delete_product(product) do
      {:ok, %Product{}} ->
        img_path = get_img_path(product)
        File.rm(img_path)

        conn
        |> put_flash(:success, gettext("Product deleted successfully"))
        |> redirect(to: admin_path(conn, :index))
      {:error, _} ->
        conn
        |> put_flash(:warning, gettext("There was a problem trying to delete your product"))
        |> redirect(to: admin_path(conn, :index))
    end
  end

  defp get_img_path(product) do
    # HACK: to get img_path, not what I'd like to do.
    # TODO: Refactor this and the default folder of the uploads
    "/" <> img_path =
      {product.image, product}
      |> Image.url()
      |> String.split("?v=")
      |> Enum.at(0)

    img_path
  end
end
