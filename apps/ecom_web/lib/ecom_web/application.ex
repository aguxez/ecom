defmodule EcomWeb.Application do
  @moduledoc false

  use Application

  def start(_type, _arg) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(EcomWeb.Endpoint, []),
    ]

    opts = [strategy: :one_for_one, name: EcomWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    EcomWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
