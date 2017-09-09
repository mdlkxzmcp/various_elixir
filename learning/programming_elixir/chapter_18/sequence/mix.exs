defmodule Sequence.Mixfile do
  use Mix.Project

  def project do
    [app: :sequence,
     version: "0.1.2",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger],
     mod:        {Sequence, []},
     env:        [initial_number: {456, 1}],
     registered: [Sequence.Server]]
  end

  defp deps do
  [
    {:distillery, "~> 1.4", runtime: false}
  ]
  end
end
