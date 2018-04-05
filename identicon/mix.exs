defmodule Identicon.Mixfile do
  use Mix.Project

  def project do
    [
      app: :identicon,
      name: "Identicon",
      escript: escript_config(),
      version: "0.1.2",
      source_url: "https://github.com/Mdlkxzmcp/various_elixir/identicon",
      elixir: "~> 1.4",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:percept, github: 'erlang/percept'},
      {:ex_doc, "~> 0.16.2"},
      {:excoveralls, "~> 0.7", only: :test},
      {:triq, github: "triqng/triq", only: :test},
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
      {:stream_data, "~> 0.4.2", only: [:test, :dev]}
    ]
  end

  defp escript_config do
    [main_module: Identicon.CLI]
  end
end
