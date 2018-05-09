defmodule TextClient.State do
  defstruct game_service: nil,
            tally: nil,
            guess: ""

  @type t() :: %TextClient.State{
          game_service: Hangman.Game.t(),
          tally: struct(),
          guess: String.t()
        }
end
