defmodule Solar do
  def power(%{classification: :C, scale: s, stations: c}) when c < 5, do: s * 1.1
  def power(%{classification: :M, scale: s, stations: c}) when c < 5, do: s * 10 * 1.1
  def power(%{classification: :X, scale: s, stations: c}) when c < 5, do: s * 1000 * 1.1
  def power(%{classification: :C, scale: s, stations: c}) when c >= 5, do: s
  def power(%{classification: :M, scale: s, stations: c}) when c >= 5, do: s * 10
  def power(%{classification: :X, scale: s, stations: c}) when c >= 5, do: s * 1000

  def no_eva(flares), do: Enum.filter(flares, &(power(&1) > 1000))

  def deadliest(flares) do
    Enum.map(flares, &power(&1))
    |> Enum.max()
  end

  def total_flare_power(flares), do: total_flare_power(flares, 0)
  def total_flare_power([], total), do: total

  def total_flare_power([%{classification: :C, scale: s} | tail], total) do
    new_total = s * 0.78 + total
    total_flare_power(tail, new_total)
  end

  def total_flare_power([%{classification: :M, scale: s} | tail], total) do
    new_total = s * 10 * 0.92 + total
    total_flare_power(tail, new_total)
  end

  def total_flare_power([%{classification: :X, scale: s} | tail], total) do
    new_total = s * 1000 * 0.68 + total
    total_flare_power(tail, new_total)
  end

  def total_flare_power_enum(flares) do
    Enum.reduce(flares, 0, &(power(&1) + &2))
  end

  def flare_list(flares) do
    for flare <- flares,
        power <- [power(flare)],
        is_deadly <- [power > 1000],
        do: %{power: power, is_deadly: is_deadly}
  end

  def flare_list_enum(flares) do
    # for flare <- flares, flare.classification == :X, do: %{power: power(flare), is_deadly: power(flare) > 1000}
    Enum.map(flares, fn flare ->
      p = power(flare)
      %{power: p, is_deadly: p > 1000}
    end)
  end
end
