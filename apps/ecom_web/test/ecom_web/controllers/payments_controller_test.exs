defmodule EcomWeb.PaymentsControllerTest do
  @moduledoc false

  use EcomWeb.ConnCase

  alias Ecom.{Repo}

  setup do
    bypass = Bypass.open()

    user =
      :user
      |> build()
      |> encrypt_password("password")
      |> insert()

    insert(:cart, user_id: user.id)
    cate = insert(:category, name: "something")
    product = insert(:product, user_id: user.id, category_id: cate.id)

    {:ok, user: user, bypass: bypass, product: product}
  end

  test "session variables get set on payments index", %{conn: conn, user: user} do
    user = update_address(user)

    conn =
      conn
      |> sign_in(user)
      |> get(payments_path(conn, :index))

    assert html_response(conn, 200) =~ "Total"
    assert get_session(conn, :proc_id)
  end

  test "process payment", %{conn: conn, user: user} do
    conn = conn |> get(page_path(conn, :index))
    proc = get_session(conn, :proc_id)

    conn =
      conn
      |> recycle()
      |> sign_in(user)
      |> get(payments_path(conn, :processed, proc_id: proc))

    assert get_flash(conn, :success) == "Payment made!"
    assert redirected_to(conn) == page_path(conn, :index)
  end

  test "redirects to login page if user isn't logged in", %{conn: conn} do
    conn = get(conn, payments_path(conn, :index))

    assert conn.status == 302
    assert redirected_to(conn) == session_path(conn, :new)
  end

  test "doesn't redirect if there's a user logged in", %{conn: conn, user: user} do
    user = update_address(user)

    conn =
      conn
      |> sign_in(user)
      |> get(payments_path(conn, :index))

    assert conn.status == 200
    assert html_response(conn, 200) =~ "Total"
  end

  test "redirects user to address form", %{conn: conn, user: user} do
    conn =
      conn
      |> sign_in(user)
      |> get(cart_path(conn, :process_cart, submit: "pay"))

    assert redirected_to(conn) == payments_path(conn, :index, proc_first: true)
  end

  test "inserts personal information for user", %{conn: conn, user: user} do
    attrs = %{
      address: "123",
      country: "Vzla",
      state: "state",
      city: "city",
      zip_code: "1210",
      tel_num: "+58123456"
    }

    conn
    |> sign_in(user)
    |> post(payments_path(conn, :update_personal_information), user: attrs)

    u = Ecom.Accounts.get_user!(user.id)

    assert u.address == attrs.address
    assert u.country == attrs.country
    assert u.state == attrs.state
    assert u.city == attrs.city
    assert u.zip_code == String.to_integer(attrs.zip_code)
    assert u.tel_num == attrs.tel_num
  end

  test "uses current address for user if it's correct", %{conn: conn, user: user} do
    attrs = %{
      address: "123",
      country: "Vzla",
      state: "state",
      city: "city",
      zip_code: "1210",
      tel_num: "+58123456"
    }

    conn
    |> sign_in(user)
    |> post(payments_path(conn, :update_personal_information), user: attrs)
    |> post(
      payments_path(conn, :update_personal_information),
      user: %{"use_current_address" => "true"}
    )

    u = Ecom.Accounts.get_user!(user.id)

    assert u.address == attrs.address
    assert u.country == attrs.country
    assert u.state == attrs.state
    assert u.city == attrs.city
    assert u.zip_code == String.to_integer(attrs.zip_code)
    assert u.tel_num == attrs.tel_num
  end

  test "if address is invalid or nil, throw error", %{conn: conn, user: user} do
    conn =
      conn
      |> sign_in(user)
      |> post(
        payments_path(conn, :update_personal_information),
        user: %{"use_current_address" => "true"}
      )

    assert get_flash(conn, :alert) ==
             "Address fields (Or your current address) can't be blank, please update them"

    assert redirected_to(conn) == payments_path(conn, :index, proc_first: true)
    assert conn.status == 302
  end

  test "redirect to address page when manually going to payments path and address is nil", %{
    conn: conn,
    user: user
  } do
    conn =
      conn
      |> sign_in(user)
      |> get(payments_path(conn, :index))

    assert redirected_to(conn) == payments_path(conn, :index, proc_first: true)
  end

  defp sign_in(conn, user) do
    post(
      conn,
      session_path(conn, :create),
      user: %{username: user.username, password: "password"}
    )
  end

  defp update_address(user) do
    attrs = %{
      address: "123",
      country: "Vzla",
      state: "state",
      city: "city",
      zip_code: "1210",
      tel_num: "+58123456"
    }

    {:ok, user} = Ecom.Accounts.update_user(user, attrs, :no_password)
    Repo.preload(user, [:cart, :products, :orders])
  end
end
