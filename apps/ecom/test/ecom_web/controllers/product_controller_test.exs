defmodule EcomWeb.ProductControllerTest do
  @moduledoc false

  use EcomWeb.ConnCase

  alias Ecom.Accounts

  setup do
    user_att = %{
      username: "test_",
      email: "some@email.com",
      password: "123456789",
      password_confirmation: "123456789"
    }

    {:ok, user} = Accounts.create_user(user_att)

    attrs = %{
      name: "some name",
      description: "some description",
      user_id: user.id
    }

    {:ok, product} = Accounts.create_product(attrs)

    {:ok, product: product, conn: build_conn()}
  end

  test "show.html shows product", %{conn: conn, product: product} do
    conn = get(conn, product_path(conn, :show, product.id))

    assert conn.status == 200
    assert html_response(conn, 200) =~ product.name
    assert html_response(conn, 200) =~ product.description
  end
end
