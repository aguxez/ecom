defmodule Ecom.Accounts.Product do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias Ecom.Accounts.{Product}


  schema "products" do
    field :name, :string
    field :user_id, :id

    # belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(%Product{} = product, attrs) do
    product
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
