defmodule GallowsWeb.HangmanView do
  use GallowsWeb, :view
  import GallowsWeb.Views.Helpers.GameStateHelper

  @spec new_game_button(Plug.Conn.t()) :: :ok
  def new_game_button(conn) do
    button("New Game", to: hangman_path(conn, :create_game))
  end

  @spec game_over?(atom) :: boolean
  def game_over?(game_state), do: game_state in [:won, :lost]

  @spec show_with_spaces(list(String.t())) :: String.t()
  def show_with_spaces(letters) when is_list(letters) do
    letters |> Enum.join(" ")
  end

  @spec turn(integer, integer) :: String.t()
  def turn(left, target) when target >= left, do: "opacity: 1"
  def turn(left, target), do: "opacity: 0.01"
end
