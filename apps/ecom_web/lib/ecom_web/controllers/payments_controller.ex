defmodule EcomWeb.PaymentsController do
  @moduledoc false

  # TODO: Module marked as Test

  use EcomWeb, :controller

  require Logger

  alias Ecom.Interfaces.Payments.Processor
  alias Ecom.Repo

  def index(conn, _params) do
    {products, total} = products_and_total(conn)

    render(conn, "index.html", products: products, total: total)
  end

  defp products_and_total(conn) do
    curr_user =
      conn
      |> current_user()
      |> Repo.preload(:cart)

    products = Map.values(curr_user.cart.products)
    total =
      products
      |> Enum.map(fn product -> product["price"] * String.to_integer(product["value"]) end)
      |> Enum.sum()

    {products, total}
  end

  def create(conn, %{"stripeToken" => token}) do
    {_, total} = products_and_total(conn)
    params = %{token: token, total: total}

    case Processor.create_purchase(params, :stripe) do
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

  rescue
    :exit -> IO.inspect("EXIT TIMEOUT")
  end

  def checkout(conn, _params) do
    {_, total} = products_and_total(conn)

    render(conn, "checkout.html", total: total)
  end
end
