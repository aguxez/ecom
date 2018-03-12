use Mix.Releases.Config,
  default_release: :ecom,
  default_environment: Mix.env()

environment :dev do
  set dev_mode: true
  set include_erts: false
  set cookie: 32 |> :crypto.strong_rand_bytes() |> Base.encode64() |> String.to_atom()
end

environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: 32 |> :crypto.strong_rand_bytes() |> Base.encode64() |> String.to_atom()
  set vm_args: "rel/vm.args.eex"
  set pre_start_hook: "rel/hooks/migrate.sh"
end

release :ecom do
  set version: "0.1.0"
  set applications: [:ecom, :ecom_web, elixir_make: :load]
end
