defmodule MyList do


  def len([]),             do: 0
  def len([ _head | tail ]), do: 1 + len(tail)


  def square([]),            do: []
  def square([ head | tail ]), do: [ head * head | square(tail) ]


  def add_1([]),            do: []
  def add_1([ head | tail ]), do: [ head + 1 | add_1(tail) ]


  def map([[], _func]),           do: []
  def map([ head | tail ], func), do: [ func.(head) | map(tail, func) ]


  def sum(list), do: do_sum(list, 0)

  defp do_sum([], total),              do: total
  defp do_sum([ head | tail ], total), do: do_sum(tail, head + total)


  def reduce([], value, _func), do: value
  def reduce([ head | tail ], value, func) do
    reduce(tail, func.(head, value), func)
  end


  def mapsum(list, func), do: do_mapsum(list, 0, func)

  defp do_mapsum([], total, _func), do: total
  defp do_mapsum([ head | tail ], total, func) do
    do_mapsum(tail, func.(head) + total, func)
  end


  def max(list), do: search_max(list, 0)

  defp search_max([], max), do: max
  defp search_max([ head | tail ], current_max) when current_max > head do
    search_max(tail, current_max)
  end
  defp search_max([ head | tail ], current_max) when current_max < head do
    search_max(tail, head)
  end


  def span(from, to), do: do_span(from, to, [])

  defp do_span(from, to, list) when from == to, do: list ++ [to]
  defp do_span(from, to, list) do
    list ++ [ from | do_span(from + 1, to, list) ]
  end

end



defmodule Swapper do

  def swap([]), do: []
  def swap([ a, b | tail ]), do: [ b, a | swap(tail) ]
  def swap(_), do: raise "Can't swap a list with an odd number of elements."
end



defmodule WeatherHistory do

  def for_location([], _target_loc), do: []
  def for_location([ head = [_, target_loc, _, _] | tail], target_loc) do
    [ head | for_location(tail, target_loc) ]
  end
  def for_location([ _ | tail], target_loc), do: for_location(tail, target_loc)

  def test_data do
    [
      [1366225622, 26, 15, 0.125],
      [1366225622, 27, 15, 0.45],
      [1366225622, 28, 21, 0.25],
      [1366229222, 26, 19, 0.081],
      [1366229222, 27, 17, 0.468],
      [1366229222, 28, 15, 0.60],
      [1366232822, 26, 22, 0.095],
      [1366232822, 27, 21, 0.05],
      [1366232822, 28, 24, 0.03],
      [1366236422, 26, 17, 0.025]
    ]
  end

end
