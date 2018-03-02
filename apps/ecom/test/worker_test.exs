defmodule Ecom.WorkerTests do
  @moduledoc false

  use Ecom.DataCase

  alias Ecom.{Repo, Worker}
  alias Ecom.Accounts.{User, Product}

  setup do
    user =
      :user
      |> build()
      |> encrypt_password("password")
      |> insert()

    insert(:cart, user_id: user.id)

    product = params_for(:product, user_id: user.id)
    user_params = params_for(:user)

    {:ok, user: user, product: product, user_params: user_params}
  end

  describe "worker" do
    test "updates user with correct credentials", %{user: user} do
      attrs = %{password: "m2481369", password_confirmation: "m2481369"}
      new_user = Worker.update_user(user, "password", attrs)

      assert {:ok, :accept} = new_user
    end

    test "doesn't update user with invalid curr_password", %{user: user} do
      attrs = %{password: "m2481369", password_confirmation: "m2481369"}
      new_user = Worker.update_user(user, "passworddd", attrs)

      assert {:error, :wrong_pass} = new_user
    end

    test "doesn't update user with invalid password attrs", %{user: user} do
      attrs = %{password: "m2481369", password_confirmation: "m24813699"}
      new_user = Worker.update_user(user, "password", attrs)

      assert {:error, %Ecto.Changeset{}} = new_user
    end

    ####

    test "creates product when user is admin", %{user: user, product: product} do
      changeset = Ecto.Changeset.change(user, %{is_admin: true})
      {:ok, user} = Repo.update(changeset)

      assert {:ok, %Product{}} = Worker.create_product(user, product)
    end

    test "can't create product if not admin", %{user: user, product: product} do
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

    test "empties user cart on correct proc_id", %{user: user} do
      user = Repo.preload(user, :cart)
      action = Worker.empty_user_cart(user, "123", "123")

      assert {:ok, :empty} = action
      assert user.cart.products == %{}
    end

    ####

    test "query returns correct products as tuples", %{user: user} do
      product = insert(:product, user_id: user.id)
      params = [%{"id" => product.id, "value" => "12"}]
      action = Worker.select_multiple_from(Product, params)

      assert [{product, "12"}] == action
    end
  end
end
