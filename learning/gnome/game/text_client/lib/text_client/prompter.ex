defmodule TextClient.Prompter do
  alias TextClient.State

  def accept_move(game = %State{}) do
    IO.gets("Your guess: ")
    |> check_input(game)
  end

  defp check_input({:error, reason}, _game) do
    IO.puts("Game ended because #{reason}")
    exit(:normal)
  end

  defp check_input(_eof = nil, _game) do
    IO.puts("Looks like you gave up...")
    exit(:normal)
  end

  defp check_input(input, game = %State{}) do
    input =
      input
      |> String.trim()
      |> String.downcase()

    cond do
      input =~ ~r/\A[a-z]\z/ ->
        Map.put(game, :guess, input)

      true ->
        IO.puts("please enter a single letter")
        accept_move(game)
    end
  end
end
