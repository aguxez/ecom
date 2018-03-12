defmodule Ecom.Accounts.Order do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias Ecom.Accounts.{User, Product, Order, ProductOrders}

  @derive {Poison.Encoder, except: [:__meta__]}

  schema "orders" do
    belongs_to(:user, User)

    many_to_many(:products, Product, join_through: ProductOrders)

    timestamps()
  end

  def changeset(%Order{} = order, attrs) do
    order
    |> cast(attrs, ~w(user_id)a)
    |> foreign_key_constraint(:user_id)
    |> validate_required(:user_id)
  end
end
