defmodule BeliefStructure.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :belief_structure,
      version: @version,
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      dialyzer: [plt_add_deps: :transitive],
      preferred_cli_env: preferred_cli_env(),
      test_coverage: [tool: ExCoveralls]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
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

  defp deps do
    [
      code_consistency_deps()
    ]
    |> Enum.concat()
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

  defp aliases do
    [
      ensure_consistency: ["test", "dialyzer", "credo --strict", "inch", "coveralls"]
    ]
  end
end
