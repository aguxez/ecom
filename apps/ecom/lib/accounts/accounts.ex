defmodule Ecom.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false

  alias Ecom.Repo
  alias Ecom.Accounts.{User, Product, Cart, CartProducts}

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    User
    |> Repo.all()
    |> Repo.preload([:products, :cart])
  end

  @doc """
  Gets a single users.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_users!(123)
      %User{}

      iex> get_users!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id) do
    User
    |> Repo.get!(id)
    |> Repo.preload(:products)
    |> Repo.preload(:cart)
  end

  @doc """
  Creates a users.

  ## Examples

      iex> create_users(%{field: value})
      {:ok, %User{}}

      iex> create_users(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a users.

  ## Examples

      iex> update_users(users, %{field: new_value})
      {:ok, %User{}}

      iex> update_users(users, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs, :no_password) do
    user
    |> User.changeset(attrs, :no_password)
    |> Repo.update()
  end

  def update_user(%User{} = user, attrs, []) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_users(users)
      {:ok, %User{}}

      iex> delete_users(users)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking users changes.

  ## Examples

      iex> change_users(users)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  @doc """
  Returns the list of products.

  ## Examples

      iex> list_products()
      [%Product{}, ...]

  """
  def list_products do
    Product
    |> Repo.all()
    |> Repo.preload(:user)
  end

  @doc """
  Gets a single product.

  Raises `Ecto.NoResultsError` if the Product does not exist.

  ## Examples

      iex> get_product!(123)
      %Product{}

      iex> get_product!(456)
      ** (Ecto.NoResultsError)

  """
  def get_product!(id) do
    Product
    |> Repo.get!(id)
    |> Repo.preload(:user)
  end

  @doc """
  Creates a product.

  ## Examples

      iex> create_product(%{field: value})
      {:ok, %Product{}}

      iex> create_product(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_product(attrs \\ %{}) do
    %Product{}
    |> Product.changeset(attrs)
    |> Ecto.Changeset.cast_assoc(:user, with: &User.changeset/2)
    |> Repo.insert()
  end

  @doc """
  Updates a product.

  ## Examples

      iex> update_product(product, %{field: new_value})
      {:ok, %Product{}}

      iex> update_product(product, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_product(%Product{} = product, attrs) do
    product
    |> Product.changeset(attrs)
    |> Ecto.Changeset.cast_assoc(:user, with: &User.changeset/2)
    |> Repo.update()
  end

  @doc """
  Deletes a Product.

  ## Examples

      iex> delete_product(product)
      {:ok, %Product{}}

      iex> delete_product(product)
      {:error, %Ecto.Changeset{}}

  """
  def delete_product(%Product{} = product) do
    Repo.delete(product)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking product changes.

  ## Examples

      iex> change_product(product)
      %Ecto.Changeset{source: %Product{}}

  """
  def change_product(%Product{} = product) do
    Product.changeset(product, %{})
  end

  ################ Carts

  def list_carts do
    Cart
    |> Repo.all()
    |> Repo.preload(:user)
  end

  def get_cart!(id) do
    Cart
    |> Repo.get!(id)
    |> Repo.preload(:user)
  end

  def create_cart(attrs \\ %{}) do
    %Cart{}
    |> Cart.changeset(attrs)
    |> Ecto.Changeset.cast_assoc(:user, with: &User.changeset/2)
    |> Repo.insert()
  end

  def update_cart(%Cart{} = cart, attrs) do
    cart
    |> Cart.changeset(attrs)
    |> Ecto.Changeset.cast_assoc(:user, with: &User.changeset/2)
    |> Repo.update()
  end

  def delete_cart(%Cart{} = cart) do
    Repo.delete(cart)
  end

  def change_cart(%Cart{} = cart) do
    Cart.changeset(cart, %{})
  end

  ########## CartProducts

  def list_cart_products do
    CartProducts
    |> Repo.all()
    |> Repo.preload([:cart, :product])
  end

  def get_cart_product!(id) do
    CartProducts
    |> Repo.get!(id)
    |> Repo.preload([:cart, :product])
  end

  def create_cart_product(attrs \\ %{}) do
    %CartProducts{}
    |> CartProducts.changeset(attrs)
    |> Repo.insert()
  end

  def update_cart_product(%CartProducts{} = cart_products, attrs) do
    cart_products
    |> CartProducts.changeset(attrs)
    |> Repo.update()
  end

  def delete_cart_product(%CartProducts{} = cart_products) do
    Repo.delete(cart_products)
  end

  def change_cart_product(%CartProducts{} = cart_products) do
    CartProducts.changeset(cart_products, %{})
  end
end
