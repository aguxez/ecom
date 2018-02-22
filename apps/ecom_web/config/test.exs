use Mix.Config

# Guardian config
config :ecom_web, EcomWeb.Guardian,
  issuer: "ecom_web",
  secret_key: "j74Hv7ni8wozhdgRPv+GxFkmUh+ZVIuDHTJJ1t6Va/tgHDBP+RSdMVqyOnFauAUS"

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ecom_web, EcomWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
