defmodule EcomWeb.AccountController do
  @moduledoc false

  use EcomWeb, :controller

  alias Ecom.Accounts
  alias Ecom.Accounts.User

  def index(conn, _params) do
    user = current_user(conn, [:id])
    changeset = User.changeset(%User{}, %{})

    render(conn, "index.html", user: user, changeset: changeset)
  end

  def update(conn, %{"user" => user_params}) do
    user = current_user(conn, "everything")
    attrs = %{password: user_params["new_password"], password_confirmation: user_params["new_password_confirmation"]}

    with true <- Comeonin.Argon2.checkpw(user_params["password"], user.password_digest),
         {:ok, %User{}} <- Accounts.update_user(user, attrs)
      do
        conn
        |> put_flash(:success, "Cuenta actualizada correctamente")
        |> redirect(to: account_path(conn, :index))
      else
        false ->
          conn
          |> put_flash(:alert, "Contraseña actual incorrecta")
          |> redirect(to: account_path(conn, :index))
        {:error, changeset} ->
          conn
          |> put_flash(:warning, "No se pudo actualizar tu cuenta")
          |> render("index.html", changeset: changeset, user: user)
      end
  end
end
