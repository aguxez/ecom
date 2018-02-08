defmodule Ecom.Accounts.User do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias Ecom.Accounts.{User}

  @derive {Poison.Encoder, except: [:__meta__]}

  schema "users" do
    field :email,           :string
    field :username,        :string
    field :password_digest, :string
    field :is_admin,        :boolean, default: false

    # Virtuals
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, ~w(email username password password_confirmation)a)
    |> validate_required(~w(email username password password_confirmation)a)
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 8)
    |> validate_length(:password_confirmation, min: 8)
    |> validate_confirmation(:password)
    |> put_pass_hash()
  end

  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, Comeonin.Argon2.add_hash(password, hash_key: :password_digest))
  end
  defp put_pass_hash(changeset), do: changeset
end
