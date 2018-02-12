defmodule Ecom.Accounts.Product do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias Ecom.Accounts.{User, Product}

  # Authorization Behaviour
  @behaviour Bodyguard.Policy


  schema "products" do
    field :name, :string

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(%Product{} = product, attrs) do
    product
    |> cast(attrs, [:name, :user_id])
    |> validate_required([:name, :user_id])
  end

  def authorize(:create_products, %User{is_admin: true}, _), do: :ok
  def authorize(:create_products, %User{is_admin: false}, _), do: {:error, :unauthorized}
end
