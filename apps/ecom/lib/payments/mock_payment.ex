defmodule Ecom.Payments.MockPayment do
  @moduledoc false

  def send_items(_items) do
    {:ok, "somelink"}
  end
end
