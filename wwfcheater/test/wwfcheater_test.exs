defmodule WwfcheaterTest do
  use ExUnit.Case
  doctest Wwfcheater

  test "We can't spell any words without any tiles" do
    assert Wwfcheater.pick('', '') == ''
  end
  test "We can't spell an empty word" do
    assert Wwfcheater.pick('abc', '') == ''
  end
  test "We can't spell a word without any tiles" do
    assert Wwfcheater.pick('', 'abc') == ''
  end
  test "We can't spell any part of a word when we don't have matching tiles" do
    assert Wwfcheater.pick('abc', 'd') == ''
  end
  test "We can pick a tile for a one letter word" do
    assert Wwfcheater.pick('abc', 'a') == 'a'
  end
end
