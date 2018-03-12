use Mix.Config

config :ecom, env: :dev

# Configure your database
config :ecom, Ecom.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "ecom_dev",
  hostname: "localhost",
  pool_size: 10

# import_config "dev.secret.exs"
