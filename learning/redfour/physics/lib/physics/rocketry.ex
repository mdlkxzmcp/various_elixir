defmodule Physics.Rocketry do

  # require IEx
  import Converter
  import Calcs
  import Physics.Laws

  @earth Planet.select[:earth]

  def orbital_speed(height), do: orbital_speed(@earth, height)
  def orbital_speed(planet, height) do
    newtons_gravitational_constant() * planet.mass / orbital_radius(planet, height)
      |> square_root
  end

  def orbital_acceleration(height), do: orbital_acceleration(@earth,height)
  def orbital_acceleration(planet, height) do
    (orbital_speed(planet, height) |> squared) / orbital_radius(planet, height)
  end

  def orbital_term(height), do: orbital_term(@earth, height)
  def orbital_term(planet, height) do
    calculate_term(planet, height)
      |> seconds_to_hours
  end

  def orbital_radius_for_term(term), do: orbital_radius_for_term(@earth, term)
  def orbital_radius_for_term(planet, term) do
    newtons_gravitational_constant() * planet.mass * (term |> squared) /
    (4 * pi_squared())
      |> cube_root
  end

  defp orbital_radius(planet, height) do
    planet.radius + (height |> to_meters)
  end

  defp calculate_term(planet, height) do
    4 * pi_squared() * (orbital_radius(planet, height) |> cubed) /
    (newtons_gravitational_constant() * planet.mass)
      |> square_root
  end

end
