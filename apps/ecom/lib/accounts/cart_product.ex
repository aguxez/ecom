defmodule Ecom.Accounts.CartProduct do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias Ecom.Accounts.{Product, Cart, CartProduct}

  schema "cart_products" do
    belongs_to(:product, Product)
    belongs_to(:cart, Cart)

    # Join schema
    timestamps()
  end

  def changeset(%CartProduct{} = struct, attrs) do
    struct
    |> cast(attrs, ~w(product_id cart_id)a)
    |> foreign_key_constraint(:product_id)
    |> foreign_key_constraint(:cart_id)
    |> validate_required(~w(product_id cart_id)a)
  end
end
