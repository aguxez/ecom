defmodule Ecom.Repo.Migrations.CreateProductImagesTable do
  use Ecto.Migration

  def change do
    create table(:product_images) do
      add :image, :string
      add :product_id, references(:products)

      timestamps()
    end

    alter table(:products) do
      remove :image
    end
  end
end
