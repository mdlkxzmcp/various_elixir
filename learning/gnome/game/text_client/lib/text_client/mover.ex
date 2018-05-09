defmodule TextClient.Mover do
  alias TextClient.State

  @spec make_move(Hangman.Game.t()) :: State.t()
  def make_move(game) do
    tally = Hangman.make_move(game.game_service, game.guess)
    %State{game | tally: tally}
  end
end
