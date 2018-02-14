defmodule Ecom.Repo.Migrations.AddQuantityToProducts do
  use Ecto.Migration

  def change do
    alter table(:products) do
      add :quantity, :integer
    end
  end
end
