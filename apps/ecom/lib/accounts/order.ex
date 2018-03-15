defmodule Ecom.Accounts.Order do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias Ecom.Accounts.{User, Product, Order, ProductOrder}

  @derive {Poison.Encoder, except: [:__meta__]}

  schema "orders" do
    belongs_to(:user, User)

    has_many(:products, ProductOrder)

    timestamps()
  end

  def changeset(%Order{} = order, attrs) do
    order
    |> cast(attrs, ~w(user_id)a)
    |> foreign_key_constraint(:user_id)
    |> validate_required(:user_id)
  end
end
