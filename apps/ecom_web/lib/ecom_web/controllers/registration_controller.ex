defmodule EcomWeb.RegistrationController do
  @moduledoc false

  use EcomWeb, :controller

  alias Ecom.Interfaces.{Accounts, Checker}

  plug :scrub_params, "user" when action in [:create]

  def new(conn, _params) do
    changeset = Accounts.change_user(%Ecom.Accounts.User{})

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Checker.new_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:success, gettext("Your account has been created!"))
        |> EcomWeb.Auth.Guardian.Plug.sign_in(user)
        |> redirect(to: page_path(conn, :index))

      {:error, changeset} ->
        conn
        |> put_flash(:alert, gettext("There were some problems trying to create your account"))
        |> render("new.html", changeset: changeset)
    end
  end
end
