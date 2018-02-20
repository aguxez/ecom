defmodule Ecom.Accounts.Cart do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias Ecom.Accounts.{User, Cart}

  ##############

  schema "carts" do
    field :products, :map

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(%Cart{} = cart, attrs) do
    cart
    |> cast(attrs, ~w(products user_id)a)
    |> foreign_key_constraint(:user_id)
  end
end
