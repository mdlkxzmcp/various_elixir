defmodule Identicon do
  @moduledoc """
    Identicon is a unique image that is always the same for the same `input`.
  """

  def create_identicon(input) do
    input
    |> hash_input
    |> store_hash
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  defp hash_input(input) do
    :crypto.hash(:md5, input)
    |> :binary.bin_to_list
  end

  defp store_hash(hex) do
    %Identicon.Image{hex: hex}
  end

  defp pick_color(%Identicon.Image{hex: [r, g, b | _tail]} = image) do
    %Identicon.Image{image | color: {r, g, b}}
  end

  defp build_grid(%Identicon.Image{hex: hex} = image) do
    grid =
      hex
      |> Enum.chunk(3)
      |> Enum.map(&mirror_row/1)
      |> List.flatten
      |> Enum.with_index

    %Identicon.Image{image | grid: grid}
  end

  defp mirror_row(row) do
    [first, second | _tail] = row

    row ++ [second, first]
  end

  defp filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    grid = Enum.filter grid, fn({value, _index}) ->
      rem(value, 2) == 0
    end

    %Identicon.Image{image | grid: grid}
  end

  defp build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map = Enum.map grid, fn({_value, index}) ->
      horizontal = rem(index, 5) * 50
      vertical = div(index, 5) * 50

      top_left = {horizontal, vertical}
      bottom_right = {horizontal + 50, vertical + 50}

      {top_left, bottom_right}
    end

    %Identicon.Image{image | pixel_map: pixel_map}
  end

  defp draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each pixel_map, fn({start, stop}) ->
      :egd.filledRectangle(image, start, stop, fill)
    end

    :egd.render(image)
  end

  defp save_image(image, input) do
    File.write("#{input}.png", image)
  end

end
