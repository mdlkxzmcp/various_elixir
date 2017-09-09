# Enum and Stream - Collections

## Enum

### Convert any collection into a list:
list = Enum.to_list 1..5                   # [1, 2, 3, 4, 5]

### Concatenate collections:
Enum.concat([1,2,3], [4,5,6])              # [1, 2, 3, 4, 5, 6]
Enum.concat [1,2,3], 'abc'                 # [1, 2, 3, 97, 98, 99]

### Create collections whose elements are some func of the original:
Enum.map(list, &(&1 * 10))                 # [10, 20, 30, 40, 50]
Enum.map(list, &String.duplicate("*", &1)) # ["*", "**", "***", "****", "*****"]

### Select elements by position or criteria:
Enum.at(10..20, 3)                         # 13
Enum.at(10..20, 20)                        # nil
Enum.at(10..20, 20, :no_one_here)          # no_one_here
Enum.filer(list, &(&1 > 2))                # [3, 4, 5]
Enum.filter(list, &Integer.is_even/1)      # [2, 4]
Enum.reject(list, &Integer.is_even/1)      # [1, 3, 5]

### Sort and compare eements:
Enum.sort ["there", "was", "a", "crooked", "man"]
# ["a", "crooked", "man", "there", "was"]
Enum.sort ["there", "was", "a", "crooked", "man"], &(String.length(&1) <= String.length(&2))
# ["a", "was", "man", "there", "crooked"]
Enum.max ["there", "was", "a", "crooked", "man"]
# "was"
Enum.max_by ["there", "was", "a", "crooked", "man"], &String.length/1
# "crooked"

###  Split a collection:
Enum.take(list, 3)                         # [1, 2, 3]
Enum.take_every list, 2                    # [1, 3, 5]
Enum.take_while(list, &(&1 < 4))           # [1, 2, 3]
Enum.split(list, 3)                        # {[1, 2, 3], [4, 5]}
Enum.split_while(list, &(&1 < 4))          # {[1, 2, 3], [4, 5]}

### Join a collection:
Enum.join(list)                            # "12345"
Enum.join(list, ", ")                      # "1, 2, 3, 4, 5"

### Predicate operations:
Enum.all?(list, &(&1 < 4))                 # false
Enum.any?(list, &(&1 < 4))                 # true
Enum.member?(list, 4)                      # true
Enum.empty?(list)                          # false

### Merge collections:
Enum.zip(list, [:a, :b, :c])
# [{1, :a}, {2, :b}, {3, :c}]
Enum.with_index(["once", "upon", "a", "time"])
# [{"once", 0}, {"upon", 1}, {"a", 2}, {"time", 3}]

### Fold elements into a single value:
Enum.reduce(1..100, &(&1+&2))              # 5050
Enum.reduce(["now", "is", "the", "time"],fn word, longest ->
  if String.length(word) > String.length(longest) do
    word
  else
    longest
  end
end)
# "time"
Enum.reduce(["now", "is", "the", "time"], 0, fn word, longest ->
  if String.length(word) > longest,
    do: String.length(word),
  else: longest
end)
# 4


## Exercise:

defmodule Enumiserable do
  def all?(list, condition) when is_list(list) and is_function(condition) do
    _all?(list, condition)
  end

  defp _all?([], _func), do: true
  defp _all?([head | tail], func) do
    if func.(head) do
      _all?(tail, func)
    else
      false
    end
  end


  def each(list, function) when is_list(list) and is_function(function) do
    _each(list, function)
  end

  defp _each([], _func), do: :ok
  defp _each([head | tail], func) do
    [func.(head) | _each(tail, func)]
  end


  def filter(list, condition) when is_list(list) and is_function(function) do
    _filter(list, condition, [])
  end

  defp _filter([], _func, acc), do: Enum.reverse(acc)
  defp _filter([head | tail], func, acc) do
    case func.(head) do
      true -> _filter(tail, func, [head | acc])
      false -> _filter(tail, func, acc)
    end
  end


  def split(list, place) when is_list(list) and is_integer(place) do
    _split(list, place)
  end

  defp _split([], _place), do: []
  defp _split([head | tail], place) do
    if place > 0 do
      {[head | _split(tail, place - 1)]}
    else
      {[head], [tail]}
    end
  end


  def take(list, place) when is_list(list) and is_integer(place) and place > 0 do
    _take(list, place, acc)
  end

  defp _take([], _place, acc), do: Enum.reverse(acc)
  defp _take(_list, _place, acc) when place == 0, do: Enum.reverse(acc)
  defp _take([head | tail], place) when place > 0 do
    _take(tail, place - 1, [head | acc])
  end


  def flatten(list) when is_list(list) do
    _flatten(list)
  end

  defp _flatten([]), do: []
  defp _flatten([head | tail]), do: _flatten(head) ++ _flatten(tail)
  defp _flatten(head) when not is_list(head), do: [head]

end


## Streams — Lazy Enumerables

s = Stream.map [1, 3, 5, 7], &(&1 + 1)
Enum.to_list s                              # [2, 4, 6, 8]

[1,2,3,4]
|> Stream.map(&(&1*&1))
|> Stream.map(&(&1+1))
|> Stream.filter(fn x -> rem(x,2) == 1 end)
|> Enum.to_list

IO.puts File.stream!("/usr/share/dict/words") |> Enum.max_by(&String.length/1)


### Infinite Streams
Enum.map(1..10_000_000, &(&1+1)) |> Enum.take(5)   # creates the whooole list
Stream.map(1..10_000_000, &(&1+1)) |> Enum.take(5) # creates, then takes the needed ones

### 'Personal' Streams
#### Stream.cycle
Stream.cycle(~w{ black yellow})
|> Stream.zip(1..3)
|> Enum.map(fn {class, value} ->
  ~s{<tr class="#{class}"><td>#{value}</td></tr>\n} end)
|> IO.puts

#### Stream.repeatedly
Stream.repeatedly(fn -> true end)
|> Enum.take(3)                             # [true, true, true]
Stream.repeatedly(&:random.uniform/0)
|> Enum.take(3)                             # [<float>, <float>, <float>]

#### Stream.iterate
Stream.iterate(0, &(&1+1))
|> Enum.take(5)                             # [0, 1, 2, 3, 4]
Stream.iterate(2, &(&1*&1))
|> Enum.take(5)                             # [2, 4, 16, 256, 65536]
Stream.iterate([], &[&1])
|> Enum.take(5)                             # [[], [[]], [[[]]], [[[[]]]], [[[[[]]]]]]

#### Stream.unfold
##### fn state -> { stream_value, new_state } end
Stream.unfold({0,1}, fn {f1,f2} -> {f1, {f2, f1+f2}} end)
|> Enum.take(10)                            # [0, 1, 1, 2, 3, 5, 8, 13, 21, 34]

#### Stream.resource
Stream.resource(fn -> File.open!("/usr/share/dict/words") end,
  fn file ->
    case IO.read(file, :line) do
      data when is_binary(data) -> {[data], file}
      _ -> {:halt, file}
    end
  end,
  fn file -> File.close(file) end)

defmodule Countdown do

  def sleep(seconds) do
    receive do
    after seconds * 1000 -> nil
    end
  end

  def say(text) do
    spawn fn -> :os.cmd('say #{text}') end
  end

  def timer do
    Stream.resource(
      fn ->
        {_h, _m, s} = :erlang.time
        60 - s - 1
      end,
      fn
        0 ->
          {:halt, 0}
        count ->
          sleep(1)
          { [inspect(count)], count - 1 }
      end,
      fn _ -> nil end
    )
  end
end
counter = Countdown.timer
printer = counter |> Stream.each(&IO.puts/1)
speaker = printer |> Stream.each(&Countdown.say/1)
speaker |> Enum.take(5)


## The Collectable Protocol

Enum.into 1..5, []                  # [1, 2, 3, 4, 5]
Enum.into 1..5, [100, 101 ]         # [100, 101, 1, 2, 3, 4, 5]
Enum.into IO.stream(:stdio, :line), IO.stream(:stdio, :line)


## Comprehensions

# for x <- [1, 2, 3, 4, 5], do: x * x
## [1, 4, 9, 16, 25]
# for x <- [ 1, 2, 3, 4, 5 ], x < 4, do: x * x
## [1, 4, 9]
# for x <- [1,2], y <- [5,6], do: x * y
## [5, 6, 10, 12]
for x <- [1, 2], y <- [5, 6], do: {x, y}
# [{1, 5}, {1, 6}, {2, 5}, {2, 6}]

min_maxes = [{1,4}, {2,3}, {10, 15}]
for {min,max} <- min_maxes, n <- min..max, do: n
# [1, 2, 3, 4, 2, 3, 10, 11, 12, 13, 14, 15]

first8 = [ 1,2,3,4,5,6,7,8 ]
for x <- first8, y <- first8, x >= y, rem(x*y, 10)==0, do: { x, y }
# [{5, 2}, {5, 4}, {6, 5}, {8, 5}]

reports = [ dallas: :hot, minneapolis: :cold, dc: :muggy, la: :smoggy ]
for { city, weather } <- reports, do: { weather, city }
# [hot: :dallas, cold: :minneapolis, muggy: :dc, smoggy: :la]

### Comprehensions Work on Bits, Too
for << ch <- "hello" >>, do: ch      # 'hello' (actually [104, 101, 108, 108, 111])
for << ch <- "hello" >>, do: <<ch>>  # ["h", "e", "l", "l", "o"]
for << << b1::size(2), b2::size(3), b3::size(3) >> <- "hello" >>,  do: "0#{b1}#{b2}#{b3}"
# ["0150", "0145", "0154", "0154", "0157"]

### The Value Returned by a Comprehension
for x <- ~w{ cat dog }, into: %{}, do: { x, String.upcase(x) }
# %{"cat" => "CAT", "dog" => "DOG"}
for x <- ~w{ cat dog }, into: %{"ant" => "ANT"}, do: { x, String.upcase(x) }
# %{"ant" => "ANT", "cat" => "CAT", "dog" => "DOG"}


### Exercise:

def primes(to) when is_integer(to) do
  for number <- 2..to, is_prime?(number),  do: number
end

defp is_prime?(prime?) when is_integer(prime?) do
  (2..prime? |> Enum.filter(fn num -> rem(prime?, num) == 0 end) |> length()) == 1
end


def tax_orders(orders, tax_rates) do
  for order <- orders do
    calculate_taxes(order, tax_rates)
  end
end

defp calculate_taxes([id: id, ship_to: place, net_amount: net_amount] = order, [NC: nc_tax, TX: tx_tax] = tax_rates) do
  cond do
    ^place = :NC ->
      order  ++ [total_amount: net_amount + (net_amount * nc_tax)]
    ^place  = :TX ->
      order  ++ [total_amount: net_amount + (net_amount * tx_tax)]
    _ ->
      order  ++ [total_amount: net_amount]
  end
end
