defmodule Ecom.AccountsTest do
  @moduledoc false

  use Ecom.DataCase

  alias Ecom.Accounts.User
  alias Ecom.{Accounts, Repo}

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
      price: 2
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

    test "list_products/0 returns all products" do
      user = insert(:user)
      # More products where being listed when they didn't need to.
      Enum.each(Accounts.list_products(), fn x -> Accounts.delete_product(x) end)

      product =
        :product
        |> insert(user_id: user.id)
        |> Repo.preload(:user)

      assert Accounts.list_products() == [product]
    end

    test "get_product!/1 returns the product with given id" do
      user = insert(:user)

      product =
        :product
        |> insert(user_id: user.id)
        |> Repo.preload(:user)

      assert Accounts.get_product!(product.id) == product
    end

    test "create_product/1 with valid data creates a product" do
      # 'product_fixture' calls Accounts.create_product/1
      user = insert(:user)

      assert {:ok, %Product{} = product} = {:ok, insert(:product, user_id: user.id)}
      assert product.name == "Some product name"
    end

    test "create_product/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_product(@invalid_attrs)
    end

    test "update_product/2 with valid data updates the product" do
      user = insert(:user)

      product =
        :product
        |> insert(user_id: user.id)
        |> Repo.preload(:user)

      assert {:ok, product} = Accounts.update_product(product, @update_attrs)
      assert %Product{} = product
      assert product.name == "some updated name"
    end

    test "update_product/2 with invalid data returns error changeset" do
      user = insert(:user)

      product =
        :product
        |> insert(user_id: user.id)
        |> Repo.preload(:user)

      assert {:error, %Ecto.Changeset{}} = Accounts.update_product(product, @invalid_attrs)
      assert product == Accounts.get_product!(product.id)
    end

    test "delete_product/1 deletes the product" do
      user = insert(:user)

      product =
        :product
        |> insert(user_id: user.id)
        |> Repo.preload(:user)

      assert {:ok, %Product{}} = Accounts.delete_product(product)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_product!(product.id) end
    end

    test "change_product/1 returns a product changeset" do
      user = insert(:user)

      product =
        :product
        |> insert(user_id: user.id)
        |> Repo.preload(:user)

      assert %Ecto.Changeset{} = Accounts.change_product(product)
    end
  end
end
