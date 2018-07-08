defmodule PlateSlate.Mixfile do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :plate_slate,
      version: @version,
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      dialyzer: [plt_add_deps: :transitive],
      preferred_cli_env: preferred_cli_env(),
      test_coverage: [tool: ExCoveralls]
    ]
  end

  def application do
    [
      mod: {PlateSlate.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "dev/support", "test/support"]
  defp elixirc_paths(:dev), do: ["lib", "dev/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      phoenix_deps(),
      code_consistency_deps(),
      absinthe_deps()
    ]
    |> Enum.concat()
  end

  defp phoenix_deps do
    [
      {:phoenix, "~> 1.3.3"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.2"},
      {:decimal, "~> 1.5"},
      {:postgrex, "~> 0.13.5"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.1.5", only: :dev},
      {:gettext, "~> 0.15"},
      {:cowboy, "~> 1.0"}
    ]
  end

  defp absinthe_deps do
    [
      {:absinthe, "~> 1.4.12"},
      {:absinthe_plug, "~> 1.4.5"},
      {:absinthe_phoenix, "~> 1.4"},
      {:absinthe_relay, "~> 1.4.3"}
    ]
  end

  defp code_consistency_deps do
    [
      {:credo, "~> 0.9", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.18", only: [:dev, :test], runtime: false},
      {:inch_ex, "~> 0.5", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.7", only: [:test], runtime: false}
    ]
  end

  defp preferred_cli_env do
    [
      coveralls: :test,
      "coveralls.detail": :test,
      "coveralls.post": :test,
      "coveralls.html": :test,
      ensure_consistency: :test
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"],
      ensure_consistency: ["test", "dialyzer", "credo --strict", "inch", "coveralls"]
    ]
  end
end
