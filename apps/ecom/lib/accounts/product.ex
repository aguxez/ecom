defmodule Ecom.Accounts.Product do
  @moduledoc false

  use Ecto.Schema
  use Arc.Ecto.Schema

  import Ecto.Changeset

  alias Ecom.Accounts.{User, Product}

  @derive {Poison.Encoder, except: [:__meta__]}

  # Authorization Behaviour
  @behaviour Bodyguard.Policy

  schema "products" do
    field(:name, :string)
    field(:description, :string)
    field(:image, Ecom.Uploaders.Image.Type)
    field(:quantity, :integer)
    field(:price, :integer)

    belongs_to(:user, User)

    timestamps()
  end

  @doc false
  def changeset(%Product{} = product, attrs) do
    product
    |> cast(attrs, [:name, :user_id, :description, :quantity, :price])
    |> foreign_key_constraint(:user_id)
    |> cast_attachments(attrs, [:image])
    |> validate_required([:name, :user_id, :description, :quantity, :price])
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
