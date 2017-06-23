defmodule IdenticonTest do
  use ExUnit.Case
  doctest Identicon

  test "parse_args with no args shows help" do
    argv = []
    assert  Identicon.parse_args(argv) == {:help}
  end

  test "parse_args help" do
    argv = ["help"]
    assert  Identicon.parse_args(argv) == {:help}
  end


  test "parse_args create identicon" do
    argv = ["this"]
    assert Identicon.parse_args(argv) == {"this"}
  end

end
