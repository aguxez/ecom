defmodule Ecom.Checker do
  @moduledoc false

  alias Comeonin.Argon2
  alias Ecom.Accounts.{User, Product}
  alias Ecom.Accounts

  def update_user(user, params_password, attrs) do
    with true <- Argon2.checkpw(params_password, user.password_digest),
         {:ok, %User{}} = Accounts.update_user(user, attrs)
      do
        {:ok, :accept}
    else
      false ->
        {:error, :wrong_pass}
      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def can_create_product?(user, params) do
    with :ok <- Bodyguard.permit(Product, :create_products, user),
         {:ok, %Product{} = product} = Accounts.create_product(params)
      do
        {:ok, product}
      else
        {:error, changeset} -> {:error, changeset}
    end
  end
end
