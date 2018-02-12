defmodule Ecom.GuardianTest do
  @moduledoc false

  use Ecom.DataCase

  alias Ecom.Accounts
  alias Ecom.Repo

  @usr %{email: "some@emaile", username: "agu", password: "m2481369", password_confirmation: "m2481369"}

  describe("subject_for_token for %User{} given") do
    setup do
      {:ok, user} = Accounts.create_user(@usr)

      {:ok, user: user}
    end

    test "returns user User:<id>", %{user: user} do
      assert Ecom.Guardian.subject_for_token(user, nil) == {:ok, "User:#{user.id}"}
    end

    test "returns error" do
      assert Ecom.Guardian.subject_for_token(%{some: "thing"}, nil) == {:error, :unknown_resource}
    end
  end

  describe("resource_from_claims for User given") do
    setup do
      {:ok, user} = Accounts.create_user(@usr)

      {:ok, user: user}
    end

    test "returns {:ok %User{}} tuple", %{user: user} do
      # Preloading association
      user = Repo.preload(user, :products)
      assert Ecom.Guardian.resource_from_claims(%{"sub" => "User:#{user.id}"}) == {:ok, %{user | password_confirmation: nil}}
    end

    test "returns {:error, :invalid_id} tuple" do
      assert Ecom.Guardian.resource_from_claims(%{"sub" => "User:a6a6a6"}) == {:error, :invalid_id}
      assert Ecom.Guardian.resource_from_claims(%{"sub" => "User:123ace"}) == {:error, :invalid_id}
      assert Ecom.Guardian.resource_from_claims(%{"sub" => "User:"}) == {:error, :invalid_id}
    end

    test "returns {:error, :no_result} tuple" do
      assert Ecom.Guardian.resource_from_claims(%{"sub" => "User:99999"}) == {:error, :no_result}
    end

    test "returns {:error, :invalid_claims} tuple" do
      assert Ecom.Guardian.resource_from_claims(%{"sub" => "Sample:12"}) == {:error, :invalid_claims}
    end
  end
end
