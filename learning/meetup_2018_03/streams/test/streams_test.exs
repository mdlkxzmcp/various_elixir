defmodule StreamsTest do
  use ExUnit.Case
  use ExUnitProperties
  doctest Streams
  import Streams
  alias Caffeine.Stream

  describe "repeat/0/1" do
    test "is a construct" do
      assert Stream.construct?(repeat()) == true
      assert Stream.construct?(repeat(1)) == true
    end

    property "returns the same thing always" do
      check all i <- float() do
        actual =
          repeat(i)
          |> Stream.take(10)
          |> Enum.all?(fn x -> x == i end)

        assert actual == true
      end
    end
  end

  describe "natural/0" do
    test "is a construct" do
      assert Stream.construct?(natural()) == true
    end

    test "returns consecutive natural numbers" do
      assert Stream.take(natural(), 10) == Enum.to_list(0..9)
    end
  end

  describe "integers_from/1" do
    test "is a construct" do
      assert Stream.construct?(integers_from(5)) == true
    end

    property "returns consecutive numbers from given number" do
      check all i <- integer() do
        expected = Enum.map(0..9, fn n -> n + i end)

        actual = Stream.take(integers_from(i), 10)

        assert actual == expected
      end
    end
  end

  describe "range/2/3" do
    test "is a construct" do
      assert Stream.construct?(range(2, -10)) == true
      assert Stream.construct?(range(0, 10, 3.14)) == true
    end

    property "returns numbers from the given range" do
      check all start <- integer(),
                stop <- integer() do
        expected = Enum.into(start..stop, []) |> Enum.take(10)

        actual = Stream.take(range(start, stop), 10)

        assert actual == expected
      end
    end
  end

  describe "list_stream/1" do
    test "is a construct" do
      assert Stream.construct?(list_stream([1, 2, 3])) == true
    end

    property "returns consecutive elements of a list" do
      types = [float(), boolean(), binary(), string(:ascii)]

      check all l <- list_of(one_of(types), length: 10) do
        expected = l

        actual = Stream.take(list_stream(l), 10)

        assert actual == expected
      end
    end
  end

  describe "stream_lines/1" do
    @test_file "test/stream_lines_test_file.txt"

    test "is a construct" do
      assert Stream.construct?(stream_lines(@test_file)) == true
    end

    test "properly reads the the file" do
      expected = [
        "I am the first line!\n",
        "I am the third line!\n",
        "THE GUY ABOVE IS A LIAR!\n",
        "Which one?\n",
        "\n",
        "Woah did you see that jump I made?\n"
      ]

      actual =
        @test_file
        |> stream_lines()
        |> Stream.take(10)

      assert actual == expected
    end
  end
end
