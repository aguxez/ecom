defmodule EcomWeb.AccountController do
  @moduledoc false

  use EcomWeb, :controller

  alias Ecom.Interfaces.Worker
  alias Ecom.Interfaces.Accounts

  plug(:scrub_params, "user" when action in [:update])

  def index(conn, _params) do
    user = current_user(conn, [:id])
    changeset = Accounts.change_user(%Ecom.Accounts.User{})

    render(conn, "index.html", user: user, changeset: changeset)
  end

  def update(conn, %{"user" => user_params}) do
    user = current_user(conn)

    attrs = %{
      password: user_params["new_password"],
      password_confirmation: user_params["new_password_confirmation"]
    }

    case Worker.update_user(user, user_params["password"], attrs, :password_needed) do
      {:ok, :accept} ->
        conn
        |> put_flash(:success, gettext("Account updated successfully"))
        |> redirect(to: account_path(conn, :index))

      {:error, :wrong_pass} ->
        conn
        |> put_flash(:warning, gettext("Incorrect password"))
        |> redirect(to: account_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:alert, gettext("There was a problem updating your account"))
        |> render("index.html", changeset: changeset, user: user)
    end
  end
end
