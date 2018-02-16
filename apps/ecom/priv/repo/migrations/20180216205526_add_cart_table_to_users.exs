defmodule Ecom.Repo.Migrations.AddCartTableToUsers do
  use Ecto.Migration

  def change do
    create table(:carts) do
      add :user_id, references(:users)
      add :products, {:array, :map}

      timestamps()
    end
  end
end
