defmodule SolarTest do
  use ExUnit.Case
  use Timex

  setup do
    flares = [
      %{classification: :X, stations: 10, scale: 99, date: Timex.to_date({1859, 8, 29})},
      %{classification: :M, stations: 10, scale: 5.8, date: Timex.to_date({2015, 1, 12})},
      %{classification: :M, stations: 6, scale: 1.2, date: Timex.to_date({2015, 2, 9})},
      %{classification: :C, stations: 6, scale: 3.2, date: Timex.to_date({2015, 4, 18})},
      %{classification: :M, stations: 7, scale: 83.6, date: Timex.to_date({2015, 6, 23})},
      %{classification: :C, stations: 10, scale: 2.5, date: Timex.to_date({2015, 7, 4})},
      %{classification: :X, stations: 2, scale: 72, date: Timex.to_date({2012, 7, 23})},
      %{classification: :X, stations: 4, scale: 45, date: Timex.to_date({2003, 11, 4})}
    ]

    {:ok, data: flares}
  end

  test "We have 8 solar flares", %{data: flares} do
    assert length(flares) == 8
  end

  test "Go inside, now.", %{data: flares} do
    d = Solar.no_eva(flares)
    assert length(d) == 3
  end

  test "the deadliest flare", %{data: flares} do
    d = Solar.deadliest(flares)
    assert d == 99000
  end

  test "total flare power using recursion and scaling", %{data: flares} do
    tfp = Solar.total_flare_power(flares)
    assert tfp == 147_717.966
  end

  test "total flares power using enum", %{data: flares} do
    tfp = Solar.total_flare_power_enum(flares)
    assert tfp == 228_611.7
  end

  test "a flare list with comprehensions", %{data: flares} do
    # |> IO.inspect
    Solar.flare_list(flares)
  end

  test "a flare list with enum", %{data: flares} do
    # |> IO.inspect
    Solar.flare_list_enum(flares)
  end
end
