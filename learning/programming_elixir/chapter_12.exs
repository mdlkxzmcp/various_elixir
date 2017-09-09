# Control Flow

## if and unless

if 1 == 1, do: "true part", else: "false part"
# "true part"
if 1 == 2, do: "true part", else: "false part"
# "false part"

if 1 == 1 do
  "true part"
else
  "false part"
end
# "true part"

unless 1 == 1, do: "error", else: "OK"
# "OK"
unless 1 == 2, do: "OK", else: "error"
# "OK"


## cond

defmodule FizzBuzzUp do

  def upto(n) when n > 0, do: _upto(1, n, [])

  defp _upto(_current, 0, result), do: Enum.reverse result

  defp _upto(current, left, result) do
    next_answer =
      cond do
        rem(current, 3) == 0 and rem(current, 5) == 0 ->
          "FizzBuzz"
        rem(current, 3) == 0 ->
          "Fizz"
        rem(current, 5) == 0 ->
          "Buzz"
        true ->
          current
      end
    _upto(current+1, left-1, [ next_answer | result ])
  end
end

defmodule FizzBuzzDown do

  def upto(n) when n > 0, do: _downto(n, [])

  defp _downto(0, result), do: result

  defp _downto(current, result) do
    next_answer =
      cond do
        rem(current, 3) == 0 and rem(current, 5) == 0 ->
          "FizzBuzz"
        rem(current, 3) == 0 ->
          "Fizz"
        rem(current, 5) == 0 ->
          "Buzz"
        true ->
          current
      end
    _downto(current-1, [ next_answer | result ])
  end
end

defmodule FizzBuzzString do

  def upto(n) when n > 0 do
    1..n |> Enum.map(&fizzbuzz/1)
  end

  defp fizzbuzz(n) do
    cond do
      rem(n, 3) == 0 and rem(n, 5) == 0 ->
        "FizzBuzz"
      rem(n, 3) == 0 ->
        "Fizz"
      rem(n, 5) == 0 ->
        "Buzz"
      true ->
        n
    end
  end
end

defmodule FizzBuzzMatch do

  def upto(n) when n > 0, do: 1..n |> Enum.map(&fizzbuzz/1)

  defp fizzbuzz(n), do: _fizzbuzz(n, rem(n, 3), rem(n, 5))

  defp _fizzbuzz(_n, 0, 0), do: "FizzBuzz"
  defp _fizzbuzz(_n, 0, _), do: "Fizz"
  defp _fizzbuzz(_n, _, 0), do: "Buzz"
  defp _fizzbuzz(n, _, _), do: n
end


## case

case File.open("case.ex") do
{ :ok, file } ->
  IO.puts "First line: #{IO.read(file, :line)}"
{ :error, reason } ->
  IO.puts "Failed to open file: #{reason}"
end

defmodule Users do
  dave = %{ name: "Dave", state: "TX", likes: "programming" }

  case dave do
    %{state: some_state} = person ->
      IO.puts "#{person.name} lives in #{some_state}"
    _ ->
      IO.puts "No matches"
  end

  dave = %{name: "Dave", age: 27}

  case dave do
    person = %{age: age} when is_number(age) and age >= 21 ->
      IO.puts "You are cleared to enter the Foo Bar, #{person.name}"
    _ ->
      IO.puts "Sorry, no admission"
  end
end


## Raising Exceptions

raise "Giving up"
# ** (RuntimeError) Giving up
raise RuntimeError
# ** (RuntimeError) runtime error
raise RuntimeError, message: "override message"
# ** (RuntimeError) override message


## Exercises

defmodule FizzBuzzCase do

  def upto(n), do: 1..n |> Enum.map(&_fizzbuzz/1)

  defp _fizzbuzz(n) do
    case { n, rem(n, 3), rem(n, 5) } do
      { _, 0, 0 } -> "FizzBuzz"
      { _, 0, _ } -> "Fizz"
      { _, _, 0 } -> "Buzz"
      { n, _ , _} -> n
    end
  end
end


def ok!(paramiter) do
  case paramiter do
    {:ok, data} ->
      data
    {:error, message} ->
      raise "An error occured: #{message}"
  end
end
