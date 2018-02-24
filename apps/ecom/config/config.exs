use Mix.Config

# Arc
config :arc,
  storage: Arc.Storage.Local

config :ecom, env: Mix.env()

# General application configuration
config :ecom,
  namespace: Ecom,
  ecto_repos: [Ecom.Repo]

  import_config "#{Mix.env}.exs"
