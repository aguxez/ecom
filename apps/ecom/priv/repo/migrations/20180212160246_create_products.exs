defmodule Ecom.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :name, :string
      add :user_id, references(:users), null: false

      timestamps()
    end
  end
end
