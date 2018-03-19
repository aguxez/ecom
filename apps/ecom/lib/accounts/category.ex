defmodule Ecom.Accounts.Category do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias Ecom.Accounts.{Product, Category}

  schema "categories" do
    field(:name, :string, null: false)

    has_many(:products, Product)

    timestamps()
  end

  def changeset(%Category{} = category, attrs) do
    category
    |> cast(attrs, ~w(name)a)
    |> validate_required(~w(name)a)
  end
end
