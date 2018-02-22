use Mix.Config

config :argon2_elixir,
  t_cost: 2,
  m_cost: 12

# Configure your database
config :ecom, Ecom.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "ecom_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
