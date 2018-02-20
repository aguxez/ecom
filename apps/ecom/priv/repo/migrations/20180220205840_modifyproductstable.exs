defmodule Ecom.Repo.Migrations.Modifyproductstable do
  use Ecto.Migration

  def change do
    execute "ALTER TABLE products DROP CONSTRAINT products_user_id_fkey"
    alter table(:products) do
      modify :user_id, references(:users, on_delete: :delete_all)
    end
  end
end
