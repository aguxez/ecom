defmodule EcomWeb.RegistrationController do
  @moduledoc false

  use EcomWeb, :controller

  alias Ecom.Accounts.User
  alias Ecom.Accounts

  plug :scrub_params, "user" when action in [:create]

  def new(conn, _params) do
    changeset = User.changeset(%User{}, %{})

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:success, "Cuenta creada satisfactoriamente")
        |> Ecom.Guardian.Plug.sign_in(user)
        |> redirect(to: page_path(conn, :index))
      {:error, changeset} ->
        conn
        |> put_flash(:alert, "Hubieron unos problemas al intentar registrar tu cuenta")
        |> render("new.html", changeset: changeset)
    end
  end
end
