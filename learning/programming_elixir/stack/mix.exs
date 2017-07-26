defmodule Stack.Mixfile do
  use Mix.Project

  def project do
    [app: :stack,
     name: "Stack",
     version: "0.1.0",
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
    [extra_applications: [:logger],
     mod:        {Stack, []},
     env:        [initial_stack: [5, "cat", 99]],
     registered: [Stack.Server]]
  end

  defp deps do
    [{:ex_doc, "~> 0.16.2"},
     {:earmark, "~> 1.2"},
     {:excoveralls, "~> 0.7", only: :test},
     {:excheck, "~> 0.5", only: :test},
     {:triq, github: "triqng/triq", only: :test}]
  end
end
