defmodule Identicon.Image do
  @moduledoc false

  @typedoc """
  Type that represents Image struct.
  """
  @type t(hex, color, grid, pixel_map) :: %Identicon.Image{
          hex: hex,
          color: color,
          grid: grid,
          pixel_map: pixel_map
        }
  @type t :: %Identicon.Image{hex: integer, color: integer, grid: integer, pixel_map: integer}

  defstruct hex: nil,
            color: nil,
            grid: nil,
            pixel_map: nil
end
