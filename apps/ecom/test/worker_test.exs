defmodule Ecom.WorkerTests do
  @moduledoc false

  use Ecom.DataCase

  import Ecto.Query, only: [from: 2]

  alias Ecom.{Accounts, Repo, Worker, ProductValues}
  alias Ecom.Accounts.{User, Product, Order}

  setup do
    user =
      :user
      |> build()
      |> encrypt_password("password")
      |> insert()

    cart = insert(:cart, user_id: user.id)
    category = insert(:category)
    product = insert(:product, user_id: user.id, category_id: category.id)

    ProductValues.start_link(user.id)

    product_params = params_for(:product, user_id: user.id, category_id: category.id)
    user_params = params_for(:user)

    insert(:cart_product, product_id: product.id, cart_id: cart.id)

    user = Repo.preload(user, cart: [:products], products: [], orders: [])

    {:ok, user: user, product_params: product_params, user_params: user_params, product: product}
  end

  describe "worker" do
    test "updates user with correct credentials", %{user: user} do
      attrs = %{password: "m2481369", password_confirmation: "m2481369"}
      new_user = Worker.update_user(user, "password", attrs, :password_needed)

      assert {:ok, :accept} = new_user
    end

    test "doesn't update user with invalid curr_password", %{user: user} do
      attrs = %{password: "m2481369", password_confirmation: "m2481369"}
      new_user = Worker.update_user(user, "passworddd", attrs, :password_needed)

      assert {:error, :wrong_pass} = new_user
    end

    test "doesn't update user with invalid password attrs", %{user: user} do
      attrs = %{password: "m2481369", password_confirmation: "m24813699"}
      new_user = Worker.update_user(user, "password", attrs, :password_needed)

      assert {:error, %Ecto.Changeset{}} = new_user
    end

    ####

    test "creates product when user is admin", %{user: user, product_params: product} do
      changeset = Ecto.Changeset.change(user, %{is_admin: true})
      {:ok, user} = Repo.update(changeset)

      assert {:ok, %Product{}} = Worker.create_product(user, product)
    end

    test "can't create product if not admin", %{user: user, product_params: product} do
      assert {:error, :unauthorized} = Worker.create_product(user, product)
    end

    ####

    test "signs with correct password", %{user: user} do
      assert {:ok, %User{}} = Worker.sign_in(user.username, "password")
    end

    test "doesn't sign in user with invalid password", %{user: user} do
      assert {:error, :failed} = Worker.sign_in(user.username, "some password")
    end

    ####

    test "creates new user and cart", %{user_params: params} do
      action = Worker.new_user(params)
      {:ok, user_struct} = action
      user = Repo.preload(user_struct, :cart)

      assert {:ok, %User{}} = action
      assert user.cart !== nil
    end

    ####

    test "query returns correct products as tuples", %{user: user, product: product} do
      ProductValues.save_value_for(user.id, %{id: product.id, value: "12"})

      action = Worker.zip_from(user.cart.products, user.id)

      assert [{product, "12"}] == action
    end

    ####

    test "updates user information when password is not needed", %{user: user} do
      attrs = %{address: "123"}
      action = Worker.update_user(user, [], attrs, :no_password)

      assert {:ok, :accept} = action
    end

    test "returns true if user address has an invalid field", %{user: user} do
      action = Worker.address_has_nil_field(user)

      assert true == action
    end

    test "does proper cleanup after payment", %{user: user} do
      action = Worker.after_payment(user, "12", "12")
      user = Accounts.get_user!(user.id)

      assert {:ok, :empty} = action
      assert user.cart.products == []
    end

    test "updates product", %{product: product} do
      action = Worker.update_product(product.id, %{quantity: 12})
      product = Accounts.get_product!(product.id)

      assert {:ok, %Product{}} = action
      assert product.quantity == 12
    end

    test "deletes product", %{product: product} do
      action = Worker.delete_product(product.id)

      assert {:ok, :deleted} = action

      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_product!(product.id)
      end
    end

    ####

    test "create_order creates order", %{user: user} do
      action = Worker.create_order(user)
      user = Accounts.get_user!(user.id)

      assert {:ok, :order_created} = action
      assert Accounts.list_orders() == Repo.preload(user.orders, [:products, :user])
      assert length(Accounts.list_product_orders()) == 1
    end

    test "empties user cart and creates order", %{user: user} do
      action = Worker.after_payment(user, "12", "12")
      user = Accounts.get_user!(user.id)

      order =
        Repo.one(from(o in Order, where: o.user_id == ^user.id, preload: [:products, :user]))

      assert {:ok, :empty} = action
      assert user.cart.products == []
      assert Accounts.list_orders() == [order]
    end

    test "returns error when proc_id is not valid", %{user: user} do
      action = Worker.after_payment(user, "12", "1")
      user = Accounts.get_user!(user.id)

      assert {:error, :invalid_proc_id} = action
      assert length(user.cart.products) == 1
      refute user.cart.products == []
    end

    test "mass_updates orders", %{user: user} do
      orders = insert_list(4, :order, user_id: user.id)
      statuses = ~w(pending completed denied)

      attrs =
        for order <- orders, into: %{} do
          # Worker receives ids as integers already
          {order.id, Enum.random(statuses)}
        end

      action = Worker.mass_update_orders(attrs)
      rand_order = Enum.random(orders)

      assert {:ok, :updated} = action
      assert rand_order.status in statuses
    end

    test "returns {:error, :unable_to_update} on mass_updates orders" do
      action = Worker.mass_update_orders(%{3 => "completed"})

      assert {:error, :unable_to_update} = action
    end

    ####

    test "creates category" do
      action = Worker.create_category(%{name: "Some category"})

      assert {:ok, :created} = action
    end

    test "doesn't create category on bad input" do
      action = Worker.create_category(%{something: :else})

      assert {:error, %Ecto.Changeset{}} = action
    end
  end
end
