defmodule EcomWeb.PaymentsController do
  @moduledoc false

  use EcomWeb, :controller

  require Logger

  alias Ecom.Interfaces.{Accounts, Worker, Payments.MercadoPago}
  alias Ecom.Repo
  alias EcomWeb.Plugs.VerifyParams

  plug(:scrub_params, "user" when action in [:update_personal_information])
  plug(VerifyParams, ["proc_id"] when action in [:processed])

  # Fills information before sending to index
  def index(conn, %{"proc_first" => "true"}) do
    changeset = Accounts.change_user(%Ecom.Accounts.User{})

    render(conn, "shipping.html", changeset: changeset)
  end

  def index(conn, _params) do
    user = current_user(conn)

    fields =
      user
      |> Map.take(~w(address country city state zip_code tel_num)a)
      |> Map.values()

    case nil in fields do
      true -> redirect(conn, to: payments_path(conn, :index, proc_first: true))
      false -> process_index(conn)
    end
  end

  defp process_index(conn) do
    {products, total} = products_and_total(conn)
    curr_url = current_url(conn)
    success = curr_url <> "/processed?proc_id=" <> get_session(conn, :proc_id)
    pending = curr_url <> "/pending?proc_id=" <> get_session(conn, :proc_id)
    failure = curr_url <> "/failure"


    items =
      for {product, value} <- products do
        %{
          title: product.name,
          quantity: value,
          unit_price: product.price,
          category_id: "fashion",
          currency_id: "VEF"
        }
      end

    attrs = %{items: items, back_urls: %{success: success, pending: pending, failure: failure}}

    case MercadoPago.send_items(attrs) do
      {:ok, link} ->
        render(
          conn,
          "index.html",
          products: products,
          total: total,
          link: link
        )

      {:error, _} ->
        conn
        |> put_flash(:warning, "There was an error processing your items")
        |> redirect(to: cart_path(conn, :index))
    end
  end

  def update_personal_information(conn, %{"user" => params}) do
    check_update_params(conn, params)
  end

  defp check_update_params(conn, %{"use_current_address" => "true"}) do
    user = current_user(conn)

    # Checking if selected "use current address" but there are nil fields
    case Worker.address_has_nil_field(user) do
      true -> handle_personal_information(conn, nil)
      false -> redirect(conn, to: payments_path(conn, :index))
    end
  end

  defp check_update_params(conn, params) do
    values = Map.values(params)
    personal_values = Map.drop(params, ["use_current_address"])

    case nil in values do
      true -> handle_personal_information(conn, nil)
      false -> handle_personal_information(conn, personal_values)
    end
  end

  defp handle_personal_information(conn, nil) do
    conn
    |> put_flash(
      :alert,
      gettext("Address fields (Or your current address) can't be blank, please update them")
    )
    |> redirect(to: payments_path(conn, :index, proc_first: true))
  end

  defp handle_personal_information(conn, params) do
    user = current_user(conn)

    case Worker.update_user(user, [], params, :no_password) do
      {:ok, :accept} ->
        redirect(conn, to: payments_path(conn, :index))

      {:error, changeset} ->
        conn
        |> put_flash(:warning, gettext("There are some errors in your submission"))
        |> render("shipping.html", changeset: changeset)
    end
  end

  # Gets products and total for checkout
  defp products_and_total(conn) do
    curr_user =
      conn
      |> current_user()
      |> Repo.preload(cart: [:products])

    products = Worker.zip_from(curr_user.cart.products, curr_user.id)

    total =
      products
      |> Enum.map(fn {product, value} -> product.price * value end)
      |> Enum.sum()

    {products, total}
  end

  def processed(conn, %{"proc_id" => param_proc_id}) do
    session_proc_id = get_session(conn, :proc_id)

    user =
      conn
      |> current_user()
      |> Repo.preload(cart: [:products])

    opts = [
      success: gettext("Payment made!"),
      invalid: gettext("There was a problem processing your payment!"),
      unable: gettext("There was a problem trying to update your cart")
    ]

    after_payment(conn, user, session_proc_id, param_proc_id, opts)
  end

  defp after_payment(conn, user, session_proc_id, param_proc_id, opts) do
    [success: success, invalid: invalid, unable: unable] = opts

    case Worker.after_payment(user, session_proc_id, param_proc_id) do
      {:ok, :empty} ->
        conn
        |> put_flash(:success, success)
        |> redirect(to: page_path(conn, :index))

      {:error, :invalid_proc_id} ->
        conn
        |> put_flash(:alert, invalid)
        |> redirect(to: page_path(conn, :index))

      {:error, :unable_to_empty} ->
        conn
        |> put_flash(:warning, unable)
        |> redirect(to: cart_path(conn, :index))
    end
  end

  def pending(conn, %{"proc_id" => param_proc_id}) do
    session_proc_id = get_session(conn, :proc_id)
    user =
      conn
      |> current_user()
      |> Repo.preload(cart: [:products])

    opts = [
      success: gettext("Your payment is pending confirmation but it's placed!"),
      invalid: gettext("There was a problem processing your payment!"),
      unable: gettext("There was a problem trying to update your cart")
    ]

    after_payment(conn, user, session_proc_id, param_proc_id, opts)
  end

  def failure(conn, _params) do
    conn
    |> put_flash(:alert, gettext("We coldn't process your payment"))
    |> redirect(to: page_path(conn, :index))
  end
end
