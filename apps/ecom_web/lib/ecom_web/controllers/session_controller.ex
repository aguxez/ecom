defmodule EcomWeb.SessionController do
  @moduledoc false

  # TODO: Check 'sign_in_and_remove' function

  use EcomWeb, :controller

  alias Ecom.Interfaces.{Accounts, Worker}

  plug(:scrub_params, "user" when action in [:create])

  def new(conn, _params) do
    changeset = Accounts.change_user(%Ecom.Accounts.User{})

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => %{"username" => username, "password" => password}})
      when not is_nil(username) and not is_nil(password) do
    case Worker.sign_in(username, password) do
      {:ok, user} ->
        sign_in(user, conn)

      {:error, :failed} ->
        failed_login(conn)
    end
  end

  def create(conn, _) do
    failed_login(conn)
  end

  # If 'user' exists
  defp sign_in(user, conn) do
    session_cart = get_session(conn, :user_cart)
    # `sign_in_and_remove/2` comes from the 'Helpers' module.
    conn
    |> put_flash(:success, gettext("Logged-in!"))
    |> EcomWeb.Auth.Guardian.Plug.sign_in(user)
    |> sign_in_and_remove(user, session_cart)
    |> redirect(to: page_path(conn, :index))
  end

  defp failed_login(conn) do
    conn
    |> put_flash(:alert, wrong_creds())
    |> redirect(to: session_path(conn, :new))
    |> halt()
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:success, gettext("You've been logged-out"))
    |> EcomWeb.Auth.Guardian.Plug.sign_out()
    |> redirect(to: page_path(conn, :index))
  end

  defp wrong_creds, do: gettext("Your username or password are incorrect!")
end
