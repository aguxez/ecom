defmodule Ecom.Accounts.Order do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias Ecom.Accounts.{User, Product, Order, ProductOrder}

  @derive {Poison.Encoder, except: [:__meta__]}

  schema "orders" do
    field(:status, :string, default: "pending")
    field(:values, {:array, :map}, default: [])

    belongs_to(:user, User)

    many_to_many(:products, Product, join_through: ProductOrder)

    timestamps()
  end

  def changeset(%Order{} = order, attrs) do
    order
    |> cast(attrs, ~w(user_id status values)a)
    |> foreign_key_constraint(:user_id)
    |> validate_required(:user_id)
  end
end
