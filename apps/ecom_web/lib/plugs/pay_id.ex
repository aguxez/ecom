defmodule EcomWeb.Plugs.PayID do
  @moduledoc false

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _params) do
    uuid =
      Ecto.UUID.generate()
      |> String.split("-")
      |> Enum.join()

    conn
    |> get_session(:proc_id)
    |> put_proc_id?(uuid, conn)
  end

  defp put_proc_id?(nil, uuid, conn), do: put_session(conn, :proc_id, uuid)
  defp put_proc_id?(_proc_id, _uuid, conn), do: conn
end
