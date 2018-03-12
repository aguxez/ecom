defmodule Ecom.Repo.Migrations.AddOrdersTable do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :user_id, references(:users)

      timestamps()
    end
  end
end
