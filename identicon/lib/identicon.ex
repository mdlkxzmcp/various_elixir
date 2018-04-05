defmodule Identicon do
  @moduledoc """
    Identicon is a unique image that is always the same for the same `input`.
    The file is in the format of "`input`.png"
  """
  @compile if Mix.env() == :test, do: :export_all

  alias Identicon.Image

  @doc """
  Creates an Identicon in the project directory

  Examples

      iex> Identicon.create_identicon("monkey_island")
      :ok

      iex> Identicon.create_identicon(:booze)
      ** (FunctionClauseError) no function clause matching in Identicon.create_identicon/1

  """
  @spec create_identicon(String.t()) :: :ok
  def create_identicon(input) when is_binary(input) do
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

  @spec hash_input(String.t(), atom) :: list
  defp hash_input(input, hash_type \\ :md5) when is_atom(hash_type) do
    hash_type
    |> :crypto.hash(input)
    |> :binary.bin_to_list()
  end

  @spec store_hash(list) :: Image.t()
  defp store_hash(hex) do
    %Image{hex: hex}
  end

  @spec pick_color(Image.t()) :: Image.t()
  defp pick_color(%Image{hex: [r, g, b | _tail]} = image) do
    %Image{image | color: {r, g, b}}
  end

  @spec build_grid(Image.t()) :: Image.t()
  defp build_grid(%Image{hex: hex} = image) do
    grid =
      hex
      |> Enum.chunk(3)
      |> Enum.map(&mirror_row/1)
      |> List.flatten()
      |> Enum.with_index()

    %Image{image | grid: grid}
  end

  @spec mirror_row([integer]) :: [integer]
  defp mirror_row(row) do
    [first, second | _tail] = row

    row ++ [second, first]
  end

  @spec filter_odd_squares(Image.t()) :: Image.t()
  defp filter_odd_squares(%Image{grid: grid} = image) do
    grid =
      Enum.filter(grid, fn {value, _index} ->
        rem(value, 2) == 0
      end)

    %Image{image | grid: grid}
  end

  @spec build_pixel_map(Image.t()) :: Image.t()
  defp build_pixel_map(%Image{grid: grid} = image) do
    pixel_map =
      Enum.map(grid, fn {_value, index} ->
        horizontal = rem(index, 5) * 50
        vertical = div(index, 5) * 50

        top_left = {horizontal, vertical}
        bottom_right = {horizontal + 50, vertical + 50}

        {top_left, bottom_right}
      end)

    %Image{image | pixel_map: pixel_map}
  end

  @spec draw_image(Image.t()) :: :egd.egd_image()
  defp draw_image(%Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each(pixel_map, fn {start, stop} ->
      :egd.filledRectangle(image, start, stop, fill)
    end)

    :egd.render(image)
  end

  @spec save_image(:egd.egd_image(), String.t()) :: :ok
  defp save_image(image, input) do
    File.write!("#{input}.png", image)
  end
end
