defmodule Identicon.CLI do
  @moduledoc """
  Handle the command line parsing and the dispatch to
  the various functions that end up generating a
  identicon based on the `input` provided.
  """

  @doc false
  def main(argv) do
    argv
    |> parse_args
    |> process

    System.halt(0)
  end

  @doc """
  `argv` can be -h or --help, which returns :help.

  Otherwise it is a string to transform into an identicon

  Return `input`, or `:help` if help was given.
  """
  def parse_args(argv) do
    parse =
      OptionParser.parse(
        argv,
        switches: [help: :boolean],
        aliases: [h: :help]
      )

    case parse do
      {[help: true], _, _} ->
        :help

      {_, [input], _} ->
        input

      _ ->
        :help
    end
  end

  @doc false
  def process(:help) do
    IO.puts("""

    Create a unique image that is always the same for the same `input`.
    Requires Erlang.

    usage: ./identicon <input>
    """)
  end

  @doc false
  def process(input) do
    Identicon.create_identicon(input)
  end
end
