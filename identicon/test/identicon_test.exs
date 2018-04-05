defmodule IdenticonTest do
  use ExUnit.Case
  use ExUnitProperties
  doctest Identicon

  alias Identicon.Image

  describe "hash_input/1/2" do
    test "accepts and defaults to `md5`" do
      # md5 hash of
      expected = [27, 194, 155, 54, 246, 35, 186, 130, 170, 246, 114, 79, 211, 177, 103, 24]

      assert Identicon.hash_input("md5") == expected
      assert Identicon.hash_input("md5", :md5) == expected
    end

    test "accepts sha, sha224, sha256, sha384, sha512" do
      actual =
        [:sha, :sha224, :sha256, :sha384, :sha512]
        |> Enum.map(&Identicon.hash_input("test", &1))
        |> Enum.all?(&is_list/1)

      assert actual == true
    end

    property "works for all strings" do
      check all s <- one_of([string(:ascii), string(:alphanumeric)]) do
        actual = Identicon.hash_input(s)

        assert is_list(actual) == true
      end
    end
  end
end
