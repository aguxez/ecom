defmodule Ecom.ProductTest do
  @moduledoc false

  use Ecom.DataCase

  alias Ecom.Accounts
  alias Ecom.Accounts.Product

  @valid_attrs %{"name" => "some name", "description" => "some desc"}

  test "when the description includes a script tag" do
    user = user_fixture()
    script_tag = "Hello <script type='javascript'>alert('foo');</script>"
    params = Map.merge(@valid_attrs, %{"description" => script_tag, "user_id" => user.id})
    changeset = Product.changeset(%Product{}, params)

    refute String.match?(get_change(changeset, :description), ~r/<\/script>/)
  end

  test "when the description includes an iframe tag" do
    user = user_fixture()
    iframe = "<iframe src='https://google.com'></iframe>"
    params = Map.merge(@valid_attrs, %{"description" => iframe, "user_id" => user.id})
    changeset = Product.changeset(%Product{}, params)

    refute String.match?(get_change(changeset, :description), ~r/<\/iframe>/)
  end

  test "body includes no stripped tags" do
    changeset = Product.changeset(%Product{}, @valid_attrs)
    assert get_change(changeset, :description) == @valid_attrs["description"]
  end

  defp user_fixture do
    attrs = %{
      email: "somee@email.com",
      username: "test_user",
      password: "24813699",
      password_confirmation: "24813699"
    }

    {:ok, user} = Accounts.create_user(attrs)

    user
  end
end
