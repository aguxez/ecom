defmodule Ecom.Application do
  @moduledoc false

  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      Ecom.Repo,
      {Registry, keys: :unique, name: :product_values},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ecom.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
