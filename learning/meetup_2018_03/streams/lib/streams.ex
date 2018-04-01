defmodule Streams do
  @moduledoc """
  Various implementations of the Caffeine Stream library.
  The take/1 function from Caffeine is the best way to retrive elements.
  """
  alias Caffeine.Stream
  alias Caffeine.Element

  @doc """
  Returns a construct that repeats given number an infinite amount of times.

  ## Example

      iex> Streams.repeat(3.14) |> Caffeine.Stream.take(5)
      [3.14, 3.14, 3.14, 3.14, 3.14]

  """
  @spec repeat(number) :: Element.t()
  def repeat(n \\ 3.14) when is_number(n) do
    rest = fn -> repeat(n) end
    Stream.construct(n, rest)
  end

  @doc """
  Returns a construct that streams consecutive natural numbers.

  ## Example

      iex> Streams.natural() |> Caffeine.Stream.take(5)
      [0, 1, 2, 3, 4]

  """
  @spec natural() :: Element.t()
  def natural do
    integers_from(0)
  end

  @doc """
  Returns a construct that streams consecutive integers
    starting from the given number.

  ## Example

      iex> Streams.integers_from(5) |> Caffeine.Stream.take(5)
      [5, 6, 7, 8, 9]

  """
  @spec integers_from(integer) :: Element.t()
  def integers_from(n) when is_integer(n) do
    rest = fn -> integers_from(n + 1) end
    Stream.construct(n, rest)
  end

  @doc """
  Returns a construct that streams numbers by optional `step`
    from `start` to `stop`. The stream ends when `stop` is met.

  ## Examples

      iex> Streams.range(0, 5, 1.8) |> Caffeine.Stream.take(5)
      [0, 1.8, 3.6, 5]

      iex> Streams.range(2, -4) |> Caffeine.Stream.take(5)
      [2, 1, 0, -1, -2]

  """
  @spec range(number, number, number) :: Element.t() | []
  def range(start, stop, step \\ 1)

  def range(start, stop, step) when is_number(start) and is_number(stop) and is_number(step) do
    case start < stop do
      true -> positive_range(start, stop, step)
      false -> negative_range(start, stop, step)
    end
  end

  defp positive_range(start, stop, _step) when start >= stop do
    rest = fn -> [] end
    Stream.construct(stop, rest)
  end

  defp positive_range(start, stop, step) do
    rest = fn -> positive_range(start + step, stop, step) end
    Stream.construct(start, rest)
  end

  defp negative_range(start, stop, _step) when start <= stop do
    rest = fn -> [] end
    Stream.construct(stop, rest)
  end

  defp negative_range(start, stop, step) do
    rest = fn -> negative_range(start - step, stop, step) end
    Stream.construct(start, rest)
  end

  @doc """
  Returns a construct that streams elements from the given list until it gets
    depleated.

    ## Examples

        iex> Streams.list_stream(Enum.to_list(0..3)) |> Caffeine.Stream.take(5)
        [0, 1, 2, 3]

        iex> Streams.list_stream(["I'm", "inside", "of", "a", "list", "!"])
        ...> |> Caffeine.Stream.take(5)
        ["I'm", "inside", "of", "a", "list"]

  """
  @spec list_stream(list) :: Element.t() | []
  def list_stream([]), do: []

  def list_stream([h | t]) do
    rest = fn -> list_stream(t) end
    Stream.construct(h, rest)
  end

  @doc """
  Returns a construct that streams lines from the given file until :eof.
  """
  @spec stream_lines(String.t()) :: Element.t() | []
  def stream_lines(path) do
    {:ok, pid} = File.open(path, [:read])
    stream_lines(pid, IO.read(pid, :line))
  end

  defp stream_lines(pid, :eof) do
    File.close(pid)
    []
  end

  defp stream_lines(pid, line) do
    rest = fn -> stream_lines(pid, IO.read(pid, :line)) end
    Stream.construct(line, rest)
  end
end
