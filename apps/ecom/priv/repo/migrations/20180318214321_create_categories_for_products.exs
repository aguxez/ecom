defmodule Ecom.Repo.Migrations.CreateCategoriesForProducts do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :name, :string, null: false
      add :product_id, references(:products, on_delete: :delete_all)

      timestamps()
    end
  end
end
