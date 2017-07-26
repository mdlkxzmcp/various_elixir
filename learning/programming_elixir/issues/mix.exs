defmodule Issues.Mixfile do
  use Mix.Project

  def project do
    [app: :issues,
     name: "Issues",
     version: "0.1.0",
     source_url: "https://github.com/Mdlkxzmcp/various_elixir/tree/master/learning/programming_elixir/issues",
     escript: escript_config(),
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: [
      "coveralls": :test,
      "coveralls.detail": :test,
      "coveralls.post": :test,
      "coveralls.html": :test
      ]
    ]
  end

  def application do
    [extra_applications: [:logger, :httpoison]]
  end

  defp deps do
    [{:httpoison, "~> 0.12.0"},
     {:poison, "~> 3.1"},
     {:ex_doc, "~> 0.16.2"},
     {:earmark, "~> 1.2"},
     {:excoveralls, "~> 0.7", only: :test}]
  end

  defp escript_config do
    [ main_module: Issues.CLI ]
  end
end
