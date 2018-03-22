defmodule Ecom.Interfaces.Payments.MercadoPago do
  @moduledoc false

  alias Ecom.Payments.MercadoPago

  defdelegate send_items(items), to: MercadoPago
end
