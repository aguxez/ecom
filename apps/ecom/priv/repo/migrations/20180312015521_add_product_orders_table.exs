defmodule Ecom.Repo.Migrations.AddProductOrderTable do
  use Ecto.Migration

  def change do
    create table(:product_orders) do
      add :product_id, references(:products, on_delete: :delete_all)
      add :order_id, references(:orders, on_delete: :delete_all)

      timestamps()
    end
  end
end
