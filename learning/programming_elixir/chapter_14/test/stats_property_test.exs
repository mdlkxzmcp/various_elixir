defmodule StatsPropertyTest do
  use ExUnit.Case
  use ExCheck

  describe "Stats on lists of ints" do

    property "single element lists are their own sum" do
      for_all number in real() do
        Stats.sum([number]) == number
      end
    end

    property "count not negative" do
      for_all l in list(int()), do: Stats.count(l) >= 0
    end

    property "sum equals average times count (such that)" do
      for_all l in such_that(l in list(int()) when length(l) > 0) do
        abs(Stats.sum(l) - Stats.count(l) * Stats.average(l)) < 1.0e-6
      end
    end
  end
end
