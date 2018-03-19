defmodule Ecom.Accounts.ProductImage do
  @moduledoc false

  use Ecto.Schema
  use Arc.Ecto.Schema

  import Ecto.Changeset

  alias Ecom.Accounts.{Product, ProductImage}

  schema "product_images" do
    field(:image, Ecom.Uploaders.Image.Type)

    belongs_to(:product, Product)

    timestamps()
  end

  def changeset(%ProductImage{} = product_image, attrs) do
    product_image
    |> cast(attrs, [:product_id])
    |> validate_required([:product_id])
    |> foreign_key_constraint(:product_id)
    |> cast_attachments(attrs, [:image])
  end
end
