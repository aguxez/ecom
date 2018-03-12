defmodule EcomWeb.Auth.GuardianTest do
  @moduledoc false

  use EcomWeb.ConnCase

  alias Ecom.Repo

  describe "subject_for_token for %User{} given" do
    setup do
      user = insert(:user)

      {:ok, user: user}
    end

    test "returns user User:<id>", %{user: user} do
      assert {:ok, "User:#{user.id}"} == EcomWeb.Auth.Guardian.subject_for_token(user, nil)
    end

    test "returns error" do
      assert EcomWeb.Auth.Guardian.subject_for_token(%{some: "thing"}, nil) ==
               {:error, :unknown_resource}
    end
  end

  describe "resource_from_claims for User given" do
    setup do
      user =
        :user
        |> build()
        |> encrypt_password("password")
        |> insert()

      {:ok, user: user}
    end

    test "returns {:ok %User{}} tuple", %{user: user} do
      user =
        user
        |> Repo.preload([:products, :cart, :orders])

      assert EcomWeb.Auth.Guardian.resource_from_claims(%{"sub" => "User:#{user.id}"}) ==
               {:ok, %{user | password_confirmation: nil}}
    end

    test "returns {:error, :invalid_id} tuple" do
      assert EcomWeb.Auth.Guardian.resource_from_claims(%{"sub" => "User:a6a6a6"}) ==
               {:error, :invalid_id}

      assert EcomWeb.Auth.Guardian.resource_from_claims(%{"sub" => "User:123ace"}) ==
               {:error, :invalid_id}

      assert EcomWeb.Auth.Guardian.resource_from_claims(%{"sub" => "User:"}) ==
               {:error, :invalid_id}
    end

    test "returns {:error, :no_result} tuple" do
      assert EcomWeb.Auth.Guardian.resource_from_claims(%{"sub" => "User:15951"}) ==
               {:error, :no_result}
    end

    test "returns {:error, :invalid_claims} tuple" do
      assert EcomWeb.Auth.Guardian.resource_from_claims(%{"sub" => "Sample:12"}) ==
               {:error, :invalid_claims}
    end
  end
end
