defmodule Streams.MixProject do
  use Mix.Project

  def project do
    [
      app: :streams,
      version: "1.0.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      source_url: "https://github.com/Mdlkxzmcp/various_elixir/tree/master/Streams",
      docs: [extras: ["README.md"]],
      test_coverage: [tool: ExCoveralls]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:excoveralls, "~> 0.8", only: [:test, :dev]},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
      {:stream_data, "~> 0.4.2", only: [:test, :dev]},
      {:dep_from_git, git: "https://github.com/Dzol/caffeine.git", tag: "1.1.0", app: false}
    ]
  end
end
