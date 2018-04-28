defmodule Physics.RocketryTest do
  use ExUnit.Case, async: true
  import Physics.Rocketry

  test "Orbital acceleration defaults to Earth" do
    x = orbital_acceleration(100)
    assert x == 9.515619587729839
  end

  test "Orbital acceleration for Earth at 100km" do
    orbital_acc = orbital_acceleration(100)
    assert orbital_acc == 9.515619587729839
  end

  test "Orbital term for 100km above the default - Earth" do
    term = orbital_term(100)
    assert term == 1.4
  end

  test "Orbital acceleration for Jupiter at 100km" do
    orbital_acc = orbital_acceleration(Planet.select()[:jupiter], 100)
    assert orbital_acc == 24.659005330334
  end

  test "Orbital term for Saturn at 6000km" do
    term = orbital_term(Planet.select()[:saturn], 6000)
    assert term == 4.8
  end
end
