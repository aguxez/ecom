defmodule EcomWeb.PaymentsController do
  @moduledoc false

  use EcomWeb, :controller

  require Logger

  alias Ecom.Interfaces.Worker
  alias Ecom.Accounts.Product
  alias Ecom.Repo

  def index(conn, _params) do
    {products, total} = products_and_total(conn)
    curr_url = current_url(conn)
    return = curr_url <> "/processed?proc_id=" <> get_session(conn, :proc_id)

    render(
      conn,
      "index.html",
      products: products,
      total: total,
      return: return
    )
  end

  defp products_and_total(conn) do
    curr_user =
      conn
      |> current_user()
      |> Repo.preload(:cart)

    products = Worker.select_multiple_from(Product, Map.values(curr_user.cart.products))

    total =
      products
      |> Enum.map(fn {product, value} -> product.price * value end)
      |> Enum.sum()

    {products, total}
  end

  def processed(conn, %{"proc_id" => param_proc_id}) do
    session_proc_id = get_session(conn, :proc_id)
    user = current_user(conn)

    case Worker.empty_user_cart(user, session_proc_id, param_proc_id) do
      {:ok, :empty} ->
        conn
        |> put_flash(:success, gettext("Payment made!"))
        |> redirect(to: page_path(conn, :index))

      {:error, :invalid_proc_id} ->
        conn
        |> put_flash(:alert, gettext("There was a problem processing your payment!"))
        |> redirect(to: page_path(conn, :index))

      {:error, :unable_to_empty} ->
        conn
        |> put_flash(:warning, gettext("There was a problem trying to update your cart"))
        |> redirect(to: cart_path(conn, :index))
    end
  end

  def cancelled(conn, _params) do
    redirect(conn, to: page_path(conn, :index))
  end
end
