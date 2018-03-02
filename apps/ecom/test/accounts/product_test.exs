defmodule Ecom.ProductTest do
  @moduledoc false

  use Ecom.DataCase

  alias Ecom.Accounts.Product

  @valid_attrs %{"name" => "some name", "description" => "some desc"}

  setup do
    user =
      :user
      |> build()
      |> encrypt_password("password")
      |> insert()

    {:ok, user: user}
  end

  test "when the description includes a script tag", %{user: user} do
    script_tag = "Hello <script type='javascript'>alert('foo');</script>"
    params = Map.merge(@valid_attrs, %{"description" => script_tag, "user_id" => user.id})
    changeset = Product.changeset(%Product{}, params)

    refute String.match?(get_change(changeset, :description), ~r/<\/script>/)
  end

  test "when the description includes an iframe tag", %{user: user} do
    iframe = "<iframe src='https://google.com'></iframe>"
    params = Map.merge(@valid_attrs, %{"description" => iframe, "user_id" => user.id})
    changeset = Product.changeset(%Product{}, params)

    refute String.match?(get_change(changeset, :description), ~r/<\/iframe>/)
  end

  test "body includes no stripped tags" do
    changeset = Product.changeset(%Product{}, @valid_attrs)
    assert get_change(changeset, :description) == @valid_attrs["description"]
  end
end
