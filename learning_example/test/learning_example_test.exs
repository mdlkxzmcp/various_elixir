defmodule LearningExampleTest do
  use ExUnit.Case
  doctest LearningExample

  test "uppercase doesn't change the first word" do
    assert LearningExample.uppercase("foo") == "foo"
  end

  test "uppercase converts the second word to uppercase" do
    assert LearningExample.uppercase("foo bar") == "foo BAR"
  end

  test "uppercase converts every other word to uppercase" do
    assert LearningExample.uppercase("foo bar baz whee") == "foo BAR baz WHEE"
  end


  test "unvowel doesn't change the first word" do
    assert LearningExample.unvowel("foo") == "foo"
  end

  test "unvowel removes the second word's vowel" do
    assert LearningExample.unvowel("foo bar") == "foo br"
  end

  test "unvowel removes every other word's vowel" do
    assert LearningExample.unvowel("foo bar baz whee") == "foo br baz wh"
  end
end
