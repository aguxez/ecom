defmodule EcomWeb.PaymentsNotifyController do
  @moduledoc """
  Controller in charge of receiving notifications from payments webhooks.

  Ex: MercadoPago
  """

  use EcomWeb, :controller

  def payment(conn, params) do
    IO.inspect(params, label: "PAYMENT NOTIFY")

    send_resp(conn, 200, "ok")
  end
end
