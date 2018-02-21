defmodule Ecom.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: Ecom.Repo

  alias Ecom.Accounts.{User, Cart, Product}

  def user_factory do
    %User{
      email: sequence(:email, &("email-#{&1}@example.com")),
      username: sequence(:username, &("user-#{&1}name")),
      password: "passwordd",
      password_confirmation: "passwordd"
    }
  end

  def product_factory do
    %Product{
      name: "Some product name",
      description: "Some product description",
      user_id: build(:user),
      quantity: Enum.random(1..100)
    }
  end

  def cart_factory do
    %Cart{
      user_id: build(:user)
    }
  end

  def encrypt_password(user, password) do
    user
    |> User.changeset(%{"password" => password, "password_confirmation" => password})
    |> Ecto.Changeset.apply_changes()
  end
end
