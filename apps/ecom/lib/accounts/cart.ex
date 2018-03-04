defmodule Ecom.Accounts.Cart do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias Ecom.Accounts.{User, Cart, Product, CartProducts}

  @derive {Poison.Encoder, except: [:__meta__]}

  ##############

  schema "carts" do
    belongs_to(:user, User)

    many_to_many(:products, Product, join_through: CartProducts)

    timestamps()
  end

  @doc false
  def changeset(%Cart{} = cart, attrs) do
    cart
    |> cast(attrs, ~w(user_id)a)
    |> foreign_key_constraint(:user_id)
  end
end
