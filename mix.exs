defmodule Toggle.MixProject do
  use Mix.Project

  def project do
    [
      app: :toggle,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      elixirc_options: [warnings_as_errors: true],
      dialyzer: [plt_add_apps: [:ecto_model], plt_file: {:no_warn, "priv/plts/dialyzer.plt"}],
      preferred_cli_env: [
        test: :test,
        "test.watch": :test,
        coveralls: :test,
        "coveralls.html": :test
      ],
      test_coverage: [tool: ExCoveralls],
      package: package(),
      description: description(),
      source_url: "https://github.com/vereis/toggle",
      homepage_url: "https://github.com/vereis/toggle"
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/vereis/toggle"}
    ]
  end

  defp description do
    """
    Toggle is a stupid-simple feature flagging library for Elixir w/ support for SQLite and Postgres.
    """
  end

  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Toggle.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.7.14"},
      {:phoenix_ecto, "~> 4.5"},
      {:ecto_sql, "~> 3.10"},
      {:ecto_sqlite3, ">= 0.0.0"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 1.0.0-rc.7"},
      {:floki, ">= 0.30.0", only: :test},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev},
      # {:heroicons,
      #  github: "tailwindlabs/heroicons", tag: "v2.1.1", sparse: "optimized", app: false, compile: false, depth: 1},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.1.1"},
      {:bandit, "~> 1.5"},
      {:cachex, "~> 4.0"},
      {:ecto_model, "~> 0.0.1"},
      # Lint dependencies
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:styler, "~> 1.1", only: [:dev, :test], runtime: false},
      # Test dependencies
      {:mix_test_watch, "~> 1.1", only: :test, runtime: false},
      {:excoveralls, "~> 0.16", only: :test, runtime: false},
      # Misc dependencies
      {:ex_doc, "~> 0.14", only: :dev, runtime: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind toggle", "esbuild toggle"],
      "assets.deploy": [
        "tailwind toggle --minify",
        "esbuild toggle --minify",
        "phx.digest"
      ],
      lint: ["format --check-formatted --dry-run", "credo --strict", "dialyzer"]
    ]
  end
end
