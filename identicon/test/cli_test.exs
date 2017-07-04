defmodule CliTest do
  use ExUnit.Case
  doctest Identicon

  import Identicon.CLI, only: [parse_args: 1]

  test ":help returned when no values given" do
    assert parse_args([]) == :help
  end

  test ":help returned by option parsing with -h and --help options" do
    assert parse_args(["-h"]) == :help
    assert parse_args(["--help"]) == :help
  end


  test "value returned if given" do
    assert parse_args(["summer"]) == "summer"
  end

end
