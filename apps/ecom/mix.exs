defmodule Ecom.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ecom,
      version: "0.0.1",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: Coverex.Task, ignore_modules: modules_to_ignore()]
    ]
  end

  defp modules_to_ignore do
    [
      Ecom, EcomWeb.Accounts, Ecom.Application, Ecom.Auth.Pipeline, Ecom.DataCase,
      Ecom.Guardian.Plug, Ecom.Repo, EcomWeb, EcomWeb.ChannelCase, EcomWeb.ConnCase,
      EcomWeb.Endpoint, EcomWeb.ErrorView, EcomWeb.Gettext, EcomWeb.Helpers,
      EcomWeb.Locale, EcomWeb.PageView, EcomWeb.ProductView, EcomWeb.RegistrationView,
      EcomWeb.Router, EcomWeb.Router.Helpers, EcomWeb.SessionView, EcomWeb.UserSocker, Poison.Encoder.Ecom.Accounts.User
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Ecom.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.3.0"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.2"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},

      {:react_phoenix, "~> 0.5.1"},
      {:comeonin, "~> 4.1"},
      {:argon2_elixir, "~> 1.2"},
      {:guardian, "~> 1.0"},
      {:bodyguard, "~> 2.2"},
      {:earmark, "~> 1.2"},
      {:arc, "~> 0.8.0"},
      {:arc_ecto, "~> 0.7.0"},
      {:sobelow, "~> 0.6.8"},

      {:credo, "~> 0.8.10", only: [:test, :dev]},
      {:coverex, "~> 1.4", only: [:test]},

      {:cart, in_umbrella: true},
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "test": ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
