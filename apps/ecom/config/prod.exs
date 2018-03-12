use Mix.Config

# Configure your database
config :ecom, Ecom.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "ecom_prod",
  pool_size: 15

# import_config "prod.secret.exs"
