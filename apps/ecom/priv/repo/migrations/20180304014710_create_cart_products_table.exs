defmodule Ecom.Repo.Migrations.CreateCartProductTable do
  use Ecto.Migration

  def change do
    create table(:cart_products) do
      add :cart_id, references(:carts)
      add :product_id, references(:products, on_delete: :delete_all)

      timestamps()
    end
  end
end
