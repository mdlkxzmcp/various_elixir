defmodule CalcsTest do
  use ExUnit.Case

  test "cubing" do
    val = 3 |> Calcs.cubed()
    assert val == 27
  end

  test "squaring" do
    val = 5_654_987_423 |> Calcs.squared()
    assert val == 31_978_882_754_288_180_929
  end

  test "square root" do
    val = 66_445_577 |> Calcs.square_root()
    assert val == 8151.415643923453
  end
end
