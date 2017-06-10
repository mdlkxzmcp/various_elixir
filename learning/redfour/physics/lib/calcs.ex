defmodule Calcs do

  def square_root(val), do: nth_root(2, val)
  def cube_root(val), do: nth_root(3, val)
  def squared(val), do: val * val
  def cubed(val), do: val * val * val
  def pi_squared, do: :math.pi |> squared

  def nth_root(n, x, precision \\ 1.0e-5) do
    f = fn(prev) -> ((n - 1) * prev + x / :math.pow(prev, (n-1))) / n end
    fixed_point(f, x, precision, f.(x))
  end

  defp fixed_point(_, guess, tolerance, next) when abs(guess - next) < tolerance, do: next
  defp fixed_point(f, _, tolerance, next), do: fixed_point(f, next, tolerance, f.(next))

end
