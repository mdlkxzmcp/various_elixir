defmodule TextClient.Summary do
  @spec display(Hangman.Game.t()) :: Hangman.Game.t()
  def display(game = %{tally: tally}) do
    IO.puts([
      "\n",
      "Word so far: #{Enum.join(tally.letters, " ")}\n",
      "Used letters: #{tally.used}\n",
      "Guesses left: #{tally.turns_left}\n"
    ])

    game
  end
end
