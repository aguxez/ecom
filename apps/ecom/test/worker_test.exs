defmodule Ecom.WorkerTests do
  @moduledoc false

  use Ecom.DataCase

  alias Ecom.{Repo, Worker, ProductValues}
  alias Ecom.Accounts.{User, Product}

  setup do
    user =
      :user
      |> build()
      |> encrypt_password("password")
      |> insert()

    cart = insert(:cart, user_id: user.id)

    ProductValues.start_link(user.id)

    product_params = params_for(:product, user_id: user.id)
    user_params = params_for(:user)
    product = insert(:product, user_id: user.id)

    insert(:cart_products, product_id: product.id, cart_id: cart.id)

    user = Repo.preload(user, cart: [:products])

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

    test "empties user cart on correct proc_id", %{user: user, product: product} do
      user = Repo.preload(user, :cart)
      action = Worker.empty_user_cart(user, "123", "123")

      assert {:ok, :empty} = action
      assert user.cart.products == [product]
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
  end
end
