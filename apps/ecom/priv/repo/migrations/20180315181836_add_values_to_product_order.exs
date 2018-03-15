defmodule Ecom.Repo.Migrations.AddValuesToProductOrder do
  use Ecto.Migration

  def change do
    alter table(:product_orders) do
      add :completed, :bool, default: false
      add :values, {:array, :map}, default: []
    end
  end
end
