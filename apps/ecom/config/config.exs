# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

config :gettext, default_locale: "es", locales: ~w(en es)

config :ecom, Ecom.Auth.Pipeline,
  module: Ecom.Guardian,
  error_handler: Ecom.AuthErrorHandler

# General application configuration
config :ecom,
  namespace: Ecom,
  ecto_repos: [Ecom.Repo]

# Configures the endpoint
config :ecom, EcomWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "R4Os4TllsGeSk9xT8bYoVDvXId7f2wcl+gJGRIoGCgQR+dvOKqJyKfbBzozOORNE",
  render_errors: [view: EcomWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Ecom.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
