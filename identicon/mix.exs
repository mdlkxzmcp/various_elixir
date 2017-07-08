defmodule Identicon.Mixfile do
  use Mix.Project

  def project do
    [app: :identicon,
     escript: escript_config(),
     version: "0.1.0",
     source_url: "https://github.com/Mdlkxzmcp/various_elixir/identicon",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:percept, github: 'erlang/percept'},
      {:ex_doc, "~> 0.16.1"},
    ]
  end

  defp escript_config do
    [main_module: Identicon.CLI]
  end
end
