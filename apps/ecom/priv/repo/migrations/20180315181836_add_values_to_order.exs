defmodule Ecom.Repo.Migrations.AddValuesToOrder do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :status, :string, default: "pending"
      add :values, {:array, :map}, default: []
    end
  end
end
