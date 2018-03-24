defmodule Ecom.Accounts.Product do
  @moduledoc false

  use Ecto.Schema
  use Arc.Ecto.Schema

  import Ecto.Changeset

  alias Ecom.Accounts.{
    User,
    Product,
    Cart,
    CartProduct,
    Order,
    ProductOrder,
    Category,
    ProductImage
  }

  @derive {Poison.Encoder, except: [:__meta__]}

  # Authorization Behaviour
  @behaviour Bodyguard.Policy

  schema "products" do
    field(:name, :string)
    field(:description, :string)
    field(:quantity, :integer)
    field(:price, :integer)

    belongs_to(:user, User)
    belongs_to(:category, Category)

    has_many(:product_images, ProductImage, on_delete: :delete_all)

    many_to_many(:orders, Order, join_through: ProductOrder, on_delete: :delete_all)
    many_to_many(:carts, Cart, join_through: CartProduct)

    timestamps()
  end

  @doc false
  def changeset(%Product{} = product, attrs) do
    product
    |> cast(attrs, ~w(name user_id description quantity price category_id)a)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:category_id)
    |> foreign_key_constraint(:products, name: :product_orders_product_id_fkey)
    |> validate_required(~w(name user_id description quantity price category_id)a)
    |> strip_unsafe_desc(attrs)
  end

  # Saving Markdown
  defp strip_unsafe_desc(product, %{"description" => nil}) do
    product
  end

  defp strip_unsafe_desc(product, %{"description" => description}) do
    {:safe, clean_desc} = Phoenix.HTML.html_escape(description)
    put_change(product, :description, clean_desc)
  end

  defp strip_unsafe_desc(product, _) do
    product
  end

  def authorize(:create_products, %User{is_admin: true}, _), do: :ok
  def authorize(:create_products, %User{is_admin: false}, _), do: {:error, :unauthorized}
end
