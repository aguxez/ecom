defmodule Ecom.Accounts.ProductImageTest do
  @moduledoc false

  use Ecom.DataCase

  alias Ecom.Accounts.ProductImage, as: Image

  setup do
    user = insert(:user)
    pro_params = params_for(:product, user_id: user.id)
    string_params = for {k, v} <- pro_params, do: {to_string(k), v}
    product = Map.merge(img_fixture(), string_params)

    {:ok, product: product, bad_params: pro_params}
  end

  test "changeset is valid", %{product: product} do
    changeset = Image.changeset(%Image{}, product)

    assert changeset.valid?
  end

  test "changeset is invalid", %{bad_params: params} do
    changeset = Image.changeset(%Image{}, params)

    refute changeset.valid?
  end

  defp img_fixture do
    %{
      "image" => [
        %Plug.Upload{
          content_type: "image/jpeg",
          filename: "1a03a1f6-1050-49b1-890e-411987f302ba.jpeg",
          path: "/tmp/plug-1521/multipart-1521484013-731865999265189-1"
        },
        %Plug.Upload{
          content_type: "image/jpeg",
          filename: "1a03a1f6-1050-49b1-890e-41198702ba.jpeg",
          path: "/tmp/plug-1521/multipart-1521484013-741865999265189-1"
        }
      ]
    }
  end
end
