defmodule EcomWeb.SessionController do
  @moduledoc false

  use EcomWeb, :controller

  import Comeonin.Argon2, only: [checkpw: 2, dummy_checkpw: 0]

  alias Ecom.Interfaces.{Accounts, Worker}

  plug :scrub_params, "user" when action in [:create]

  def new(conn, _params) do
    changeset = Accounts.change_user(%Ecom.Accounts.User{})

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => %{"username" => username, "password" => password}})
  when not is_nil(username) and not is_nil(password) do

    case Worker.sign_in(username, password) do
      {:ok, {new_user, new_password}} ->
        sign_in(new_user, new_password, conn)

      {:error, :failed} ->
        sign_in(nil, "", conn)
    end
  end

  def create(conn, _) do
    failed_login(conn)
  end


  # If 'user' doesn't exist
  defp sign_in(nil, _password, conn) do
    failed_login(conn)
  end

  # If 'user' exists
  defp sign_in(user, plain_password, conn)  do
    if checkpw(plain_password, user.password_digest) do
      session_cart = get_session(conn, :user_cart)
      # If 'plain_password' matches 'password_digest'
      conn
      |> put_flash(:success, gettext("Logged-in!"))
      |> EcomWeb.Auth.Guardian.Plug.sign_in(user)
      # from the 'Helpers' module
      |> sign_in_and_remove(user, session_cart)
      |> redirect(to: page_path(conn, :index))
    else
      # If 'plain_password' is invalid
      failed_login(conn)
    end
  end

  defp failed_login(conn) do
    dummy_checkpw()

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

  defp wrong_creds,
    do: gettext("Your username or password are incorrect!")
end
