defmodule Times do

  def double n do
    n * 2
  end

  def triple n do
    n * 3
  end

  def quadriple n do
    n |> double |> double
  end

end


defmodule Factorial do

  def of(0), do: 1
  def of(n) when n > 0, do: n * of(n - 1)
end


defmodule SumAndGCD do

  def sum([]), do: []
  def sum([head | tail]) do
    head + sum(tail)
  end

  def gcd(x, 0) when x > 0, do: x
  def gcd(x, y) when x and y > 0, do: gcd(y, rem(x, y))

end

defmodule Params do

  def func(p1, p2 \\ 123)

  def func(p1, p2) when is_list(p1) do
    "You said #{p2} with a list"
  end

  def func(p1, p2) do
    "You passed in #{p1} and #{p2}"
  end

end

IO.puts Params.func(99)
IO.puts Params.func(99, "cat")
IO.puts Params.func([99])
IO.puts Params.func([99], "dog")

defmodule Attributes do
  @attr "one"
  def first, do: @attr
  @attr "two"
  def second, do: @attr
end

IO.puts "#{Example.second} #{Example.first}"

#########

IO.puts "#{}"
IO.puts "#{System.cwd}"
System.cmd "git", ["status"]
