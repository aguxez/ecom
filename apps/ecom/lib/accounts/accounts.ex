defmodule Ecom.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false

  alias Ecom.Repo
  alias Ecom.Accounts.{User, Product, Cart, CartProduct, Order, ProductOrder, Category, ProductImage}

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    User
    |> Repo.all()
    |> Repo.preload([:products, :cart, :orders])
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
    |> Repo.preload(cart: [:products], products: [], orders: [])
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
    |> Repo.preload([:user, :orders, :carts, :category, :product_images])
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
    |> Repo.preload([:user, :orders, :carts, :category, :product_images])
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
    |> Repo.preload([:user, :products])
  end

  def get_cart!(id) do
    Cart
    |> Repo.get!(id)
    |> Repo.preload([:user, :products])
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

  ########## CartProduct

  def list_cart_products do
    CartProduct
    |> Repo.all()
    |> Repo.preload([:cart, :product])
  end

  def get_cart_product!(id) do
    CartProduct
    |> Repo.get!(id)
    |> Repo.preload([:cart, :product])
  end

  def create_cart_product(attrs \\ %{}) do
    %CartProduct{}
    |> CartProduct.changeset(attrs)
    |> Repo.insert()
  end

  def update_cart_product(%CartProduct{} = cart_products, attrs) do
    cart_products
    |> CartProduct.changeset(attrs)
    |> Repo.update()
  end

  def delete_cart_product(%CartProduct{} = cart_products) do
    Repo.delete(cart_products)
  end

  def change_cart_product(%CartProduct{} = cart_products) do
    CartProduct.changeset(cart_products, %{})
  end

  #### Order
  def list_orders do
    Order
    |> Repo.all()
    |> Repo.preload([:products, :user])
  end

  def get_order!(id) do
    Order
    |> Repo.get!(id)
    |> Repo.preload([:products, :user])
  end

  def create_order(attrs \\ %{}) do
    %Order{}
    |> Order.changeset(attrs)
    |> Repo.insert()
  end

  def update_order(%Order{} = order, attrs) do
    order
    |> Order.changeset(attrs)
    |> Repo.update()
  end

  def delete_order(%Order{} = order) do
    Repo.delete(order)
  end

  def change_order(%Order{} = order) do
    Order.changeset(order, %{})
  end

  #### ProductOrder

  def list_product_orders do
    ProductOrder
    |> Repo.all()
    |> Repo.preload([:order, :product])
  end

  def get_product_order!(id) do
    ProductOrder
    |> Repo.get!(id)
    |> Repo.preload([:order, :product])
  end

  def create_product_order(attrs \\ %{}) do
    %ProductOrder{}
    |> ProductOrder.changeset(attrs)
    |> Repo.insert()
  end

  def update_product_order(%ProductOrder{} = product_order, attrs) do
    product_order
    |> ProductOrder.changeset(attrs)
    |> Repo.update()
  end

  def delete_product_order(%ProductOrder{} = product_order) do
    Repo.delete(product_order)
  end

  def change_product_order(%ProductOrder{} = product_order) do
    ProductOrder.changeset(product_order, %{})
  end

  ####

  def list_categories do
    Category
    |> Repo.all()
    |> Repo.preload(:products)
  end

  def get_category!(id) do
    Category
    |> Repo.get!(id)
    |> Repo.preload(:products)
  end

  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end

  def change_category(%Category{} = category) do
    Category.changeset(category, %{})
  end

  ####

  def create_product_image(attrs) do
    %ProductImage{}
    |> ProductImage.changeset(attrs)
    |> Repo.insert()
  end
end
