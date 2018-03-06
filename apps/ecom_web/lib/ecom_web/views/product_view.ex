defmodule EcomWeb.ProductView do
  @moduledoc false

  use EcomWeb, :view

  alias Ecom.Repo

  def markdown(body) do
    {:ok, html, []} = Earmark.as_html(body)
    raw(html)
  end

  def submit_button(conn, id) do
    conn
    |> EcomWeb.Helpers.current_user()
    |> disable_product?(conn, id)
  end

  defp disable_product?(nil, conn, id) do
    products = Plug.Conn.get_session(conn, :user_cart)
    disabled = Map.has_key?(products, id)

    text_and_button_action(disabled)
  end

  defp disable_product?(user, conn, id) do
    user = Repo.preload(user, cart: [:products])
    product_ids = Enum.map(user.cart.products, & &1.id)
    disabled = id in product_ids

    text_and_button_action(disabled)
  end

  defp text_and_button_action(true) do
    %{text: gettext("This product is already in your cart"), disabled: true}
  end

  defp text_and_button_action(false) do
    %{text: gettext("Add to your cart"), disabled: false}
  end
end
