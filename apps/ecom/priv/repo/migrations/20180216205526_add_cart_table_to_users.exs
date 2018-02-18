defmodule Ecom.Repo.Migrations.AddCartTableToUsers do
  use Ecto.Migration

  def change do
    create table(:carts) do
      add :user_id, references(:users), null: false
      add :products, {:array, :map}, default: []

      timestamps()
    end
  end
end