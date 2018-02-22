# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Gettext
config :gettext,
  default_locale: "es",
  locales: ~w(en es)

config :ecom_web,
  namespace: EcomWeb,
  ecto_repos: [Ecom.Repo]

# Guardian
config :ecom_web, EcomWeb.Auth.Guardian,
  issuer: "ecom_web",
  secret_key: "iw54jtTr2Gop851VIYsQ77MsvCxk0lDJOdbtPB7t+470lKlst1ly5ygbqcws9nWT"

config :ecom_web, EcomWeb.Auth.Pipeline,
  module: EcomWeb.Auth.Guardian,
  error_handler: EcomWeb.Auth.AuthErrorHandler

# Configures the endpoint
config :ecom_web, EcomWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "R4Os4TllsGeSk9xT8bYoVDvXId7f2wcl+gJGRIoGCgQR+dvOKqJyKfbBzozOORNE",
  render_errors: [view: EcomWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: EcomWeb.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :ecom_web, :generators,
  context_app: :ecom_web

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
