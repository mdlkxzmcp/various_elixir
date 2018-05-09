defmodule Dictionary.WordList do
  def start_link() do
    Agent.start_link(&word_list/0, name: __MODULE__)
  end

  @spec word_list() :: list(String.t())
  def word_list do
    "../../assets/words.txt"
    |> Path.expand(__DIR__)
    |> File.read!()
    |> String.split(~r/\n/)
  end

  @spec random_word() :: String.t()
  def random_word() do
    Agent.get(__MODULE__, &Enum.random/1)
  end
end
