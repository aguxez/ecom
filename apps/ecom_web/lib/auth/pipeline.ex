defmodule EcomWeb.Auth.Pipeline do
  @moduledoc false

  use Guardian.Plug.Pipeline, otp_app: :ecom_web

  plug(Guardian.Plug.VerifySession)
  plug(Guardian.Plug.VerifyHeader)
  plug(Guardian.Plug.LoadResource, allow_blank: true)
end
