defmodule Ecom.Repo.Migrations.AddAddressesToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :address, :string
      add :country, :string
      add :city, :string
      add :zip_code, :integer
      add :tel_num, :string
    end
  end
end
