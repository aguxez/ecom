use Mix.Releases.Config,
  default_release: :ecom,
  default_environment: Mix.env()

environment :dev do
  set dev_mode: true
  set include_erts: false
  set cookie: :crypto.strong_rand_bytes(32) |> Base.encode64() |> String.to_atom()
end

environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: :crypto.strong_rand_bytes(32) |> Base.encode64() |> String.to_atom()
  set vm_args: "rel/vm.args.eex"
end

release :ecom do
  set version: "0.1.0"
  set applications: [:ecom, :ecom_web, elixir_make: :load]
  set commands: [
    "migrate": "rel/commands/migrate.sh"
  ]
end
