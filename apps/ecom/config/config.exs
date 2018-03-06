use Mix.Config

# Arc
config :arc, storage: Arc.Storage.Local

# General application configuration
config :ecom,
  namespace: Ecom,
  ecto_repos: [Ecom.Repo]

import_config "#{Mix.env()}.exs"
