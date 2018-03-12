defmodule Ecom.Accounts.User do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias Ecom.Accounts.{User, Product, Cart, Order}
  alias Comeonin.Argon2

  @derive {Poison.Encoder, except: [:__meta__]}

  # Authorization 'behaviour'
  @behaviour Bodyguard.Policy

  schema "users" do
    field(:email, :string)
    field(:username, :string)
    field(:password_digest, :string)
    field(:is_admin, :boolean, default: false)
    field(:address, :string)
    field(:country, :string)
    field(:city, :string)
    field(:state, :string)
    field(:zip_code, :integer)
    field(:tel_num, :string)

    field(:password, :string, virtual: true)
    field(:password_confirmation, :string, virtual: true)

    has_many(:products, Product)
    has_many(:orders, Order)
    has_one(:cart, Cart)

    timestamps()
  end

  def changeset(%User{} = user, attrs, :no_password) do
    user
    |> cast(
      attrs,
      ~w(email username address country city state zip_code tel_num)a
    )
    |> unique_constraint(:email)
    |> unique_constraint(:username)
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(
      attrs,
      ~w(email username password password_confirmation address country city
      state zip_code tel_num)a
    )
    |> validate_required(~w(email username password password_confirmation)a)
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 8)
    |> validate_length(:password_confirmation, min: 8)
    |> validate_confirmation(:password)
    |> unique_constraint(:email)
    |> unique_constraint(:username)
    |> put_pass_hash()
  end

  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, Argon2.add_hash(password, hash_key: :password_digest))
  end

  defp put_pass_hash(changeset), do: changeset

  # Bodyguard callback

  # Admins can do anything
  def authorize(_, %User{is_admin: true}, _), do: :ok

  # Users can't go to a page
  def authorize(:admin_panel, %User{is_admin: false}, _), do: {:error, :unauthorized}

  def authorize(_, _, _), do: {:error, :unauthorized}
end
