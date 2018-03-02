defmodule Ecom.Worker do
  @moduledoc false

  import Ecto.Query, only: [from: 2]

  alias Comeonin.Argon2
  alias Ecom.Accounts.{User, Product, Cart}
  alias Ecom.{Repo, Accounts}

  def update_user(user, params_password, attrs) do
    with true <- Argon2.checkpw(params_password, user.password_digest),
         {:ok, %User{}} <- Accounts.update_user(user, attrs) do
      {:ok, :accept}
    else
      false ->
        {:error, :wrong_pass}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def create_product(user, params) do
    with :ok <- Bodyguard.permit(Product, :create_products, user),
         {:ok, %Product{} = product} = Accounts.create_product(params) do
      {:ok, product}
    else
      {:error, changeset} -> {:error, changeset}
    end
  end

  def sign_in(username, password) do
    User
    |> Repo.get_by(username: username)
    |> do_sign_in(password)
  end

  defp do_sign_in(nil, _password) do
    {:error, :failed}
  end
  defp do_sign_in(user, password) do
    if Argon2.checkpw(password, user.password_digest) do
      {:ok, user}
    else
      Argon2.dummy_checkpw()
      {:error, :failed}
    end
  end

  def new_user(user_params) do
    with {:ok, user} <- Accounts.create_user(user_params),
         {:ok, %Cart{}} <- Accounts.create_cart(%{user_id: user.id}) do
      {:ok, user}
    else
      {:error, changeset} -> {:error, changeset}
    end
  end

  def empty_user_cart(user, sess_proc_id, param_proc_id) do
    with true <- sess_proc_id == param_proc_id,
         {:ok, %Cart{}} <- Accounts.update_cart(user.cart, %{products: %{}}) do
      {:ok, :empty}
    else
      false -> {:error, :invalid_proc_id}
      {:error, _changeset} -> {:error, :unable_to_empty}
    end
  end

  # Makes a query to select multiple items
  def select_multiple_from(module, param) do
    ids = Enum.map(param, &(&1["id"]))
    values = Enum.map(param, &(&1["value"]))
    do_select_multiple_from(module, ids, values)
  end

  # We're returning the records as a list of tuples with {Product, value}
  defp do_select_multiple_from(module, ids, values) do
    products = Repo.all(from(i in module, where: i.id in ^ids))
    Enum.zip(products, values)
  end
end
