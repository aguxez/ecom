use Mix.Config

config :ecom_web, EcomWeb.Endpoint,
  load_from_system_env: true,
  http: [port: {:system, "PORT"}],
  url: [host: "localhost", port: {:system, "PORT"}],
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true,
  root: ".",
  version: Application.spec(:ecom_web, :vsn)

# Do not print debug messages in production
config :logger, level: :info

import_config "prod.secret.exs"
