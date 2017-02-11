defmodule Wwfcheater do
  def pick _, '' do
    ''
  end
  def pick tiles, [ letter | _] do
    cond do
      Enum.member?(tiles, letter) -> [ letter ]
      true -> ''
    end
  end
end
