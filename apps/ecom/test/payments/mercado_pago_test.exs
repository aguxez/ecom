defmodule Ecom.Payments.MercadoPagoTest do
  @moduledoc false

  use Ecom.DataCase

  alias Ecom.Payments.MercadoPago

  test "mock returns {:ok, 'somelink'}" do
    assert {:ok, "somelink"} = MercadoPago.send_items([])
  end
end
