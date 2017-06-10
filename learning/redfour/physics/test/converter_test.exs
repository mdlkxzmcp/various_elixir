defmodule ConverterTest do
  use ExUnit.Case
  doctest Physics

  test "Converter works with default value for precision" do
    ls = Converter.to_light_seconds({:miles, 1000})
    assert ls == 0.00537
  end

  test "Converting to to_light_seconds from miles" do
    ls = Converter.to_light_seconds({:miles, 1000}, precision: 5)
    assert ls == 0.00537
  end


end
