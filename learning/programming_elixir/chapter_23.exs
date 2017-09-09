# Protocols

## Defining and implementing a Protocol

defprotocol Inspect do
  def inspect(thing, opts)
end

defimpl Inspect, for: PID do
  def inspect(pid, _opts) do
    "#PID" <> IO.iodata_to_binary(:erlang.pid_to_list(pid))
  end
end

defimpl Inspect, for: Reference do
  def inspect(ref, _opts) do
    '#Ref' ++ rest = :erlang.ref_to_list(ref)
    "#Reference" <> IO.iodata_to_binary(rest)
  end
end

inspect self()
# "#PID<....>"
defimpl Inspect, for: PID do
  def inspect(pid, _opts) do
    "#PID" <> IO.iodata_to_binary(:erlang.pid_to_list(pid)) <> "!"
  end
end
# warning: redefining module Inspect.PID (current version loaded from [...]
# {:module, Inspect.PID,
# <<70, ...>>, {:__impl__, 1}}
inspect self()
# "PID<....>!"


## Available Types

defprotocol Collection do
  @fallback_to_any true
  def is_collection?(value)
end

defimpl Collection, for: [BitString, List, Map, Tuple] do
  def is_collection?(_), do: true
end

defimpl Collection, for: Any do
  def is_collection?(_), do: false
end

Enum.each [ 1, 1.0, [1,2], {1,2}, %{}, "meow"], fn value ->
  IO.puts "#{inspect value}: #{Collection.is_collection?(value)}"
end


## Exercices:

# Protocols-1
defprotocol Caesar do
  @fallback_to_any true
  def encrypt(string, shift)
  def rot13(word)
end

defmodule Char do
  defmacro is_upper(char) do
    quote do
      unquote(char) > 64 and unquote(char) < 91
    end
  end

  defmacro is_lower(char) do
    quote do
      unquote(char) > 96 and unquote(char) < 123
    end
  end
end

defimpl Caesar, for: [BitString, List] do
  import Char, only: [is_upper: 1, is_lower: 1]

  def encrypt(string, shift),
    do: do_encrypt(string, shift)

  def rot13(word),
    do: do_encrypt(word, 13)


  defp do_encrypt(string, shift) when is_bitstring(string) do
    string
    |> String.to_charlist
    |> Enum.map(&shift(&1, shift))
    |> List.to_string
  end

  defp do_encrypt(string, shift) when is_list(string) do
    string
    |> Enum.map(&shift(&1, shift))
  end

  # upper case letters => 65 - 90
  defp shift(char, shift) when is_upper(char) do
    case char + rem(shift, 26) do
      char when char < 65 -> char + 26
      char when char > 91 -> char - 26
      char -> char
    end
  end

  # lower case letters => 97 - 122
  defp shift(char, shift) when is_lower(char) do
    case char + rem(shift, 26) do
      char when char < 97  -> char + 26
      char when char > 122 -> char - 26
      char -> char
    end
  end

  defp shift(char, _shift), do: char

end

defimpl Caesar, for: Any do
  def encrypt(_, _), do: message()
  def rot13(_),   do: message()
  defp message, do: IO.puts "Invalid type for encryption :<"
end


# protocols-2
defmodule WordHunter do
  @word_list "/usr/share/dict/american-english"

  def hunt(word_list \\ @word_list) do
    words =
      word_list
      |> File.stream!
      |> Stream.map(&String.trim(&1))
      |> Enum.reduce(MapSet.new, fn(word, acc) -> MapSet.put(acc, word) end)

    words
    |> Enum.reduce([], fn(word, acc) -> update_results(word, words, acc) end)
    |> IO.inspect
  end

  defp update_results(word, words, acc) do
    case rotation_exists?(word, words) do
      true  -> [ word | acc ]
      false -> acc
    end
  end

  defp rotation_exists?(word, words) do
    rotated_word = Caesar.rot13(word)
    MapSet.member?(words, rotated_word)
  end
end


## Protocols and Structs

defmodule Blob do
  defstruct content: nil
end


## Built-In Protocols

defmodule Bitmap do
  defstruct value: 0

  @doc """
  A simple accessor for the 2^bit value in an integer

  Example:

      iex> b = %Bitmap{value: 5}
      %Bitmap{value: 5}
      iex> Bitmap.fetch_bit(b,2)
      1
      iex> Bitmap.fetch_bit(b,1)
      0
      iex> Bitmap.fetch_bit(b,0)
      1
  """

  def fetch_bit(%Bitmap{value: value}, bit) do
    use Bitwise

    (value >>> bit) &&& 1
  end

  defimpl Inspect, for: Bitmap do
    import Inspect.Algebra
    def inspect(%Bitmap{value: value}, _opts) do
      concat([
        nest(
        concat([
          "%Bitmap{",
          break(""),
          nest(concat([to_string(value),
                       "=",
                       break(""),
                       as_binary(value)]),
              2),

        ]), 2),
        break(""),
        "}"])
    end
    defp as_binary(value) do
      to_string(:io_lib.format("~.2B", [value]))
    end
  end

  defimpl String.Chars, for: Bitmap do
    def to_string(bitmap) do
      import Enum
      bitmap
      |> reverse
      |> chunk(3)
      |> map(fn three_bits -> three_bits |> reverse |> join end)
      |> reverse
      |> join("_")
    end
  end

  defimpl Enumerable, for: Bitmap do
    import :math, only: [log: 1]
    def count(%Bitmap{value: value}) do
      { :ok, trunc(log(abs(value))/log(2)) + 1 }
    end

    # fifty = %Bitmap{value: 50}
    # IO.puts Enum.count fifty        # 6

    def member?(value, bit_number) do
      { :ok, 0 <= bit_number && bit_number < Enum.count(value) }
    end

    # IO.puts Enum.member? fifty, 4  # true
    # IO.puts Enum.member? fifty, 6  # false

    def reduce(bitmap, {:cont, acc}, fun) do
      bit_count = Enum.count(bitmap)
      _reduce({bitmap, bit_count}, {:cont, acc}, fun)
    end

    defp _reduce({_bitmap, -1}, {:cont, acc}, _fun), do: { :done, acc }

    defp _reduce({bitmap, bit_number}, {:cont, acc}, fun) do
      with bit = Bitmap.fetch_bit(bitmap, bit_number),
      do: _reduce({bitmap, bit_number-1}, fun.(bit, acc), fun)
    end

    defp _reduce({_bitmap, _bit_number}, {:halt, acc}, _fun), do: { :halted, acc }

    defp _reduce({bitmap, bit_number}, {:suspend, acc}, fun),
    do: { :suspended, acc, &_reduce({bitmap, bit_number}, &1, fun), fun }

    # IO.inspect Enum.reverse fifty    # [0, 1, 0, 0, 1, 1, 0]
    # IO.inspect Enum.join fifty, ":"  # "0:1:1:0:0:1:0"

  end

  defimpl Collectable, for: Bitmap do
    use Bitwise

    def into(%Bitmap{value: target}) do
      {target, fn
        acc, {:cont, next_bit} -> (acc <<< 1) ||| next_bit
        acc,  :done            -> %Bitmap{value: acc}
        _,    :halt            -> :ok
      end}
    end
  end
end


## Exercise:

defmodule MyEnum do
  def each(enumerable, fun) do
    reducer = fn(elem, _acc) ->
      fun.(elem)
      { :cont, nil }
    end

    enumerable
    |> Enumerable.reduce({:cont, nil}, reducer)

    :ok
  end

  def filter(enumerable, fun) do
    reducer = fn(elem, acc) ->
      case fun.(elem) do
        true  -> {:cont, [elem | acc]}
        false -> {:cont, acc}
      end
    end

    {:done, result} = enumerable
    |> Enumerable.reduce({:cont, []}, reducer)

    result
    |> Enum.reverse
  end

  def map(enumerable, fun) do
    reducer = fn(elem, acc) ->
      {:cont, [fun.(elem) | acc]}
    end

    {:done, result} = enumerable
    |> Enumerable.reduce({:cont, []}, reducer)

    result
    |> Enum.reverse
  end
end
