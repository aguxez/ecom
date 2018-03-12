defmodule Ecom.Repo.Migrations.AddCartTableToUsers do
  use Ecto.Migration

  def change do
    create table(:carts) do
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end
  end
end
