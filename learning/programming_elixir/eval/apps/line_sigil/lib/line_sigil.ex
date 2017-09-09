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
