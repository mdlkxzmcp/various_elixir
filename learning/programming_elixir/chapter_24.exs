# More Cool Stuff


## Writing Own Sigils

defmodule LineSigil do
  @doc """
  Implement the `~l` sigil, which takes a string containing
  multiple lines and returns a list of those lines.

  ## Example usage

      iex> import LineSigil
      iex> ~l\"""
      ...> one
      ...> two
      ...> three
      ...> \"""
      ["one", "two", "three"]
  """
  def sigil_l(lines, _opts) do
    lines |> String.trim_trailing |> String.split("\n")
  end
end

defmodule Example do
  import LineSigil

  def lines do
    ~l"""
    line 1
    line 2
    and another line in #{__MODULE__}
    """
  end
end

IO.inspect Example.lines
# ["line 1", "line 2", "and another line in Elixir.Example"]

defmodule ColorSigil do

  @color_map [
    rgb: [ red: 0xff0000, green: 0x00ff00, blue: 0x0000ff
         ],
    hsb: [ red: {0,100,100}, green: {120,100,100}, blue: {240,100,100}
         ]
  ]

  def sigil_c(color_name, []),  do: _c(color_name, :rgb)
  def sigil_c(color_name, 'r'), do: _c(color_name, :rgb)
  def sigil_c(color_name, 'h'), do: _c(color_name, :hsb)

  defp _c(color_name, color_space) do
    @color_map[color_space][String.to_atom(color_name)]
  end

  defmacro __using__(_opts) do
    quote do
      import Kernel, except: [sigil_c: 2]
      import unquote(__MODULE__), only: [sigil_c: 2]
    end
  end
end

defmodule ColorSigilExample do
  use ColorSigil

  def rgb, do: IO.inspect ~c{red}
  def hsb, do: IO.inspect ~c{red}h
end

ColorSigilExample.rgb   # 16711680
ColorSigilExample.hsb   # {0, 100, 100}


## Exercises:

defmodule CommaSigil do

  @doc """
  Implements the `~v` sigil, which takes a string containing
  multiple lines which, in turn, contain comma separated values
  and returns a list where each element is a list of values.

  ## Example usage

      iex> import CommaSigil
      iex> ~v\"""
      ...> 1,2,3
      ...> cat, dog
      ...> Elixir, Elm, Python
      ...> \"""
      [["1", "2", "3"], ["cat", "dog"], ["Elixir", "Elm", "Python"]]
  """
  def sigil_v(lines, _opts) do
    lines
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, ","))
    |> Enum.map(&trim_list(&1))
  end

  defp trim_list(list) do
    for value <- list do
      String.trim(value)
    end
  end
end


defmodule CommaSigilFloat do

  @doc """
  Implements the `~v` sigil, which takes a string containing
  multiple lines which, in turn, contain comma separated values
  and returns a list where each element is a list of values.
  If a value is a number, it is represented as such.

  ## Example usage

      iex> import CommaSigilFloat
      iex> ~v\"""
      ...> 1.1,2,3
      ...> cat, , dog
      ...> Elixir, Elm, Python
      ...> \"""
      [[1.1, 2, 3], ["cat", "dog"], ["Elixir", "Elm", "Python"]]
  """
  def sigil_v(lines, _opts) do
    lines
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, ","))
    |> Enum.map(&parse_cell(&1))
    |> Enum.map(&List.delete(&1, ""))
  end


  defp parse_cell(cell) do
    for value <- cell do
      String.trim(value)
      |> convert_to_numbers
    end
  end

  defp convert_to_numbers(value) do
    case Integer.parse(value) do
      {num, ""}     -> num
      {_num, _rest} -> float_number(value)
      :error        -> value
    end
  end

  defp float_number(value) do
    case Float.parse(value) do
      {num, _rest} -> num
      :error       -> raise("This is bad!")
    end
  end

end


defmodule CommaSigilCSV do

  @doc """
  Implements the `~v` sigil, which takes a string containing
  multiple lines which, in turn, contain comma separated values
  and returns a list where each element is a list of values.
  If a value is a number, it is represented as such. In case
  the first line is a list of the column names the return is
  a list of keyword lists.

  ## Example usage

      iex> import CommaSigilCSV
      iex> ~v\"""
      ...> Item, Qty, Price
      ...> Sprite, 1, 1.25
      ...> Batteries, 12, 16
      ...> \"""
      [
        [Item: "Sprite", Qty: 1, Price: 1.25],
        [Item: "Batteries", Qty: 12, Price: 16.00]
      ]
  """
  def sigil_v(lines, _opts) do
    lines
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, ","))
    |> Enum.map(&parse_cell(&1))
    |> is_proper_CSV?
    |> create_a_CSV_if_possible
  end


  defp parse_cell(cell) do
    for value <- cell do
      value
      |> String.trim
      |> float_number
      |> nil_empty_values
    end
  end

  defp float_number(value) do
    case Float.parse(value) do
      {num, _rest} -> num
      :error       -> value
    end
  end

  defp nil_empty_values(value) do
    case value == "" do
      true  -> nil
      false -> value
    end
  end

  defp is_proper_CSV?(lines) do
    {[first_line], rest} = Enum.split(lines, 1)

    case Enum.all?(rest, &length(&1) == length(first_line)) do
      true  ->
        { Enum.all?(first_line, &is_bitstring/1), first_line, rest }
      false ->
        { true, first_line, rest }
    end
  end

  defp create_a_CSV_if_possible({false, lines}) when is_list(lines), do: lines
  defp create_a_CSV_if_possible({false, first_line, rest}) do
    Enum.concat(first_line, rest)
  end

  defp create_a_CSV_if_possible({true, first_line, rest}) do
    column_names = Enum.map(first_line, &String.to_atom/1)

    Enum.map(rest, &Enum.zip(column_names, &1))
  end

end
