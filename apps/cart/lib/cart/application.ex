defmodule Cart.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: Cart.Worker.start_link(arg)
      # {Cart.Worker, arg},
      Cart.Sup.SingleCartSup,
      {Registry, [keys: :unique, name: Cart.SingleCartReg]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Cart.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
