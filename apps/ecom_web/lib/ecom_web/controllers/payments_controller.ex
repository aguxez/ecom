defmodule EcomWeb.PaymentsController do
  @moduledoc false

  # TODO: Module marked as Test

  use EcomWeb, :controller

  require Logger

  alias Ecom.Interfaces.Payments.Processor
  alias Ecom.Interfaces.Accounts
  alias Ecom.Repo

  def index(conn, _params) do
    curr_user = conn |> current_user() |> Repo.preload(:cart)

    products =
      if curr_user do
        Map.values(curr_user.cart.products)
      else
        # If the user is not logged in then the item is added to the key ':user_cart' in session.
        Map.values(get_session(conn, :user_cart))
      end

    render(conn, "index.html", products: products)
  end

  def create(conn, %{"stripeToken" => token}) do
    case Processor.create_purchase(token, :stripe) do
      {:ok, :accepted} ->
        conn
        |> put_flash(:success, gettext("Payment done!"))
        |> redirect(to: cart_path(conn, :index))

      {:error, {:failed, payment}} ->
        Logger.debug("PAYMENT FAILED: #{payment}")

        conn
        |> put_flash(:alert, gettext("There was an error processing your payment"))
        |> redirect(to: cart_path(conn, :index))

      {:error, {:req_error, payment}} ->
        Logger.debug("REQUEST ERROR: #{payment}")

        conn
        |> put_flash(:alert, gettext("There was a request error, contact if the error persist"))
        |> redirect(to: page_path(conn, :index))
    end
  end
end
