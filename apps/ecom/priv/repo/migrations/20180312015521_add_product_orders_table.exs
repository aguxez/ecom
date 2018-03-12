defmodule Ecom.Repo.Migrations.AddProductOrdersTable do
  use Ecto.Migration

  def change do
    create table(:product_orders) do
      add :product_id, references(:products)
      add :order_id, references(:orders)

      timestamps()
    end
  end
end
