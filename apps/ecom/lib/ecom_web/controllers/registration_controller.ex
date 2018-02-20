defmodule EcomWeb.RegistrationController do
  @moduledoc false

  use EcomWeb, :controller

  alias Ecom.Accounts.{User}
  alias Ecom.Accounts

  plug :scrub_params, "user" when action in [:create]

  def new(conn, _params) do
    changeset = User.changeset(%User{}, %{})

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    # user_cart = get_session(conn, :user_cart_name)

    with {:ok, user} <- Accounts.create_user(user_params),
         {:ok, %Accounts.Cart{}} <- Accounts.create_cart(%{user_id: user.id}) do
      conn
      |> put_flash(:success, gettext("Your account has been created!"))
      |> Ecom.Guardian.Plug.sign_in(user)
      |> redirect(to: page_path(conn, :index))
    else
      {:error, changeset} ->
        conn
        |> put_flash(:alert, gettext("There were some problems trying to create your account"))
        |> render("new.html", changeset: changeset)
    end
  end
end
