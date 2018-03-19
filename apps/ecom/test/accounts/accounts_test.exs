defmodule Ecom.AccountsTest do
  @moduledoc false

  use Ecom.DataCase

  alias Ecom.Accounts.User
  alias Ecom.{Accounts, Repo}

  setup do
    user = insert(:user)
    order = insert(:order, user_id: user.id)
    category = insert(:category)
    product =
      :product
      |> insert(user_id: user.id, category_id: category.id)
      |> Repo.preload([:user, :carts, :orders, :category])

    product_order = insert(:product_order, product_id: product.id, order_id: order.id)

    {:ok, user: user, product_order: product_order, order: order, product: product, category: category}
  end

  describe "users" do
    @valid_attrs %{
      email: "email@email.com",
      username: "someusername",
      password: "123456789",
      password_confirmation: "123456789"
    }
    @update_attrs %{
      email: "some@updatedemail",
      username: "some updated username",
      password: "87654321",
      password_confirmation: "87654321"
    }
    @invalid_attrs %{email: nil, username: nil}

    def user_fixture(mod_attr) do
      {:ok, user} = Accounts.create_user(mod_attr)

      user
    end

    test "create_user/1 with valid data creates a user" do
      user = insert(:user)

      assert %User{} = user
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the users" do
      user = user_fixture(@valid_attrs)

      assert {:ok, user} = Accounts.update_user(user, @update_attrs, [])
      assert %User{} = user
      assert user.email == "some@updatedemail"
      assert user.username == "some updated username"
    end

    test "delete_users/1 deletes the users" do
      user = insert(:user)

      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_users/1 returns a users changeset" do
      user = insert(:user)

      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end

    test "password_hash value gets set to hash" do
      changeset = User.changeset(%User{}, @valid_attrs)

      assert Comeonin.Argon2.checkpw(
               @valid_attrs.password,
               get_change(changeset, :password_digest)
             )
    end

    test "password_hash value doest not get set if password is nil" do
      changeset =
        User.changeset(%User{}, %{@update_attrs | password: nil, password_confirmation: nil})

      refute Ecto.Changeset.get_change(changeset, :password_digest)
    end
  end

  describe "products" do
    alias Ecom.Accounts.Product

    @valid_attrs %{name: "some name", description: "some description", quantity: 10, price: 0}
    @update_attrs %{
      name: "some updated name",
      description: "some updated desc",
      quantity: 11,
      price: 2,
      category_id: 1
    }
    @invalid_attrs %{name: nil}

    def product_fixture(attrs \\ %{}) do
      attr = %{
        email: "some@emai.com",
        username: "test_user",
        password: "24813699",
        password_confirmation: "24813699"
      }

      {:ok, user} = Accounts.create_user(attr)

      {:ok, product} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Map.merge(%{user_id: user.id})
        |> Accounts.create_product()

      Repo.preload(product, :user)
    end

    test "list_products/0 returns all products", %{user: user, category: category} do
      # More products were being listed when they didn't need to.
      Enum.each(Accounts.list_products(), &Accounts.delete_product(&1))

      product = insert(:product, user_id: user.id, category_id: category.id)

      assert Accounts.list_products() == [Repo.preload(product, [:carts, :orders, :user, :category])]
    end

    test "get_product!/1 returns the product with given id", %{product: product} do
      product = Accounts.get_product!(product.id)

      assert Accounts.get_product!(product.id) == product
    end

    test "create_product/1 with valid data creates a product", %{product: product} do
      assert {:ok, %Product{} = product} = {:ok, product}
      assert product.name == "Some product name"
    end

    test "create_product/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_product(@invalid_attrs)
    end

    test "update_product/2 with valid data updates the product", %{category: category, product: product} do
      assert {:ok, product} = Accounts.update_product(product, %{@update_attrs | category_id: category.id})
      assert %Product{} = product
      assert product.name == "some updated name"
    end

    test "update_product/2 with invalid data returns error changeset", %{product: product} do
      product = Accounts.get_product!(product.id)

      assert {:error, %Ecto.Changeset{}} = Accounts.update_product(product, @invalid_attrs)
      assert product == Accounts.get_product!(product.id)
    end

    test "delete_product/1 deletes the product", %{product: product} do
      assert {:ok, %Product{}} = Accounts.delete_product(product)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_product!(product.id) end
    end

    test "change_product/1 returns a product changeset", %{product: product} do
      assert %Ecto.Changeset{} = Accounts.change_product(product)
    end
  end

  describe "orders" do
    alias Ecom.Accounts.Order

    test "list_products returns a list of all orders", %{order: order} do
      order = Repo.preload(order, [:products, :user])
      assert Accounts.list_orders() == [order]
    end

    test "get_order! returns order with valid id", %{order: order} do
      assert Accounts.get_order!(order.id) == Repo.preload(order, [:products, :user])
    end

    test "create_order creates order with valid attrs", %{user: user} do
      order_attrs = params_for(:order, user_id: user.id)

      assert {:ok, order} = Accounts.create_order(order_attrs)
      assert %Order{} = order
      assert order.user_id == user.id
    end

    test "update_order update order with valid attrs", %{order: order} do
      action = Accounts.update_order(order, %{})

      assert {:ok, order} = action
      assert %Order{} = order
    end

    test "delete_order deletes an order", %{order: order} do
      action = Accounts.delete_order(order)

      assert {:ok, _} = action
    end

    test "change_order returns changeset", %{order: order} do
      action = Accounts.change_order(order)

      assert %Ecto.Changeset{} = action
    end
  end

  describe "product_orders" do
    alias Ecom.Accounts.ProductOrder

    test "list_product_orders returns a list of product orders", %{product_order: p_order} do
      p_order = Repo.preload(p_order, [:product, :order])
      assert Accounts.list_product_orders() == [p_order]
    end

    test "get_product_order! returns a product order by id", %{product_order: p_order} do
      assert Accounts.get_product_order!(p_order.id) == Repo.preload(p_order, [:product, :order])
    end

    test "create_product_order creates a product order", %{order: order, product: product} do
      p_order_attrs = params_for(:product_order, order_id: order.id, product_id: product.id)

      assert {:ok, product_order} = Accounts.create_product_order(p_order_attrs)
      assert %ProductOrder{} = product_order
      assert product_order.product_id == product.id
      assert product_order.order_id == order.id
    end

    test "update_product_order updates product order", %{
      product: product,
      order: order,
      product_order: p_order
    } do
      action =
        Accounts.update_product_order(p_order, %{product_id: product.id, order_id: order.id})

      assert {:ok, p_order} = action
      assert %ProductOrder{} = p_order
    end

    test "delete_product_order deletes product oder", %{product_order: p_order} do
      assert {:ok, %ProductOrder{}} = Accounts.delete_product_order(p_order)
    end

    test "change_product_order returns product order changeset", %{product_order: p_order} do
      action = Accounts.change_product_order(p_order)

      assert %Ecto.Changeset{} = action
    end
  end

  describe "categories" do
    alias Ecom.Accounts.Category

    test "list_categories returns a list of all categories" do
      Enum.each(Accounts.list_categories(), &Accounts.delete_category(&1))
      category = insert(:category)

      assert Accounts.list_categories() == [Repo.preload(category, :products)]
    end

    test "get_category! returns a category", %{category: category} do
      assert Accounts.get_category!(category.id) == Repo.preload(category, [:products])
    end

    test "create_category creates a new category" do
      category = Accounts.create_category(%{name: "some category"})

      assert {:ok, %Category{}} = category
    end

    test "update_category updates given category", %{category: category} do
      action = Accounts.update_category(category, %{name: "other name"})

      assert {:ok, %Category{} = cate} = action
      assert cate.name == "other name"
    end

    test "delete_category deletes given category", %{category: category} do
      action = Accounts.delete_category(category)

      assert {:ok, %Category{}} = action
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_category!(category.id) end
    end

    test "change_category creates changeset for given category", %{category: category} do
      action = Accounts.change_category(category)

      assert %Ecto.Changeset{} = action
    end
  end
end
