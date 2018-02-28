defmodule EcomWeb.Plugs.PayID do
  @moduledoc false

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _params) do
    uuid =
      Ecto.UUID.generate()
      |> String.split("-")
      |> Enum.join()

    pay_id = get_session(conn, :proc_id)

    if pay_id do
      conn
    else
      put_session(conn, :proc_id, uuid)
    end
  end
end
