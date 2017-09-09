# Tasks and Agents

## Tasks

defmodule Fib do
  def of(0), do: 0
  def of(1), do: 1
  def of(n), do: Fib.of(n-1) + Fib.of(n-2)
end

IO.puts "Start the task"
worker = Task.async(fn -> Fib.of(20) end)
IO.puts "Do something else..."
IO.puts "Wait for the task"
result = Task.await(worker)
IO.puts "The result is #{result}"

worker = Task.async(Fib, :of, [20])
result = Task.await(worker)
IO.puts "The result is #{result}"


## Tasks and Supervision

import Supervisor.Spec

children = [
  worker(Task, [ fn -> Fib.of(20) end])
]

supervise children, strategy: :one_for_one


## Agents

{ :ok, count } = Agent.start(fn -> 0 end)
# {:ok, #PID<....>}
Agent.get(count, &(&1))
# 0
Agent.update(count, &(&1+1))
# :ok
Agent.update(count, &(&1+1))
# :ok
Agent.get(count, &(&1))
# 2

Agent.start(fn -> 1 end, name: Sum)
# {:ok, #PID<....>}
Agent.get(Sum, &(&1))
# 1
Agent.update(Sum, &(&1+99))
# :ok
Agent.get(Sum, &(&1))
# 100

defmodule Frequency do
  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def add_word(word) do
    Agent.update(__MODULE__,
      fn map ->
        Map.update(map, word, 1, &(&1+1))
      end)
  end

  def count_for(word) do
    Agent.get(__MODULE__, fn map -> map[word] end)
  end

  def words do
    Agent.get(__MODULE__, fn map -> Map.keys(map) end)
  end
end

Frequency.start_link
# {:ok, #PID<....>}
Frequency.add_word "Max"
# :ok
Frequency.words
# ["Max"]
Frequency.add_word "was"
# :ok
Frequency.add_word "here"
# :ok
Frequency.add_word "he"
# :ok
Frequency.add_word "was"
# :ok
Frequency.words
# ["Max", "he", "here", "was"]
Frequency.count_for "Max"
# 1
Frequency.count_for "was"
# 2


## A Bigger Example

defmodule Dictionary do

  @name {:global, __MODULE__}

  ##
  # External API

  def start_link,
  do: Agent.start_link(fn -> %{} end, name: @name)

  def add_words(words),
  do: Agent.update(@name, &do_add_words(&1, words))

  def anagrams_of(word),
  do: Agent.get(@name, &Map.get(&1, signature_of(word)))

  ##
  # Internal implementation

  defp do_add_words(map, words),
  do: Enum.reduce(words, map, &add_one_word(&1, &2))

  defp add_one_word(word, map),
  do: Map.update(map, signature_of(word), [word], &[word|&1])

  defp signature_of(word),
  do: word |> to_charlist |> Enum.sort |> to_string
end

defmodule WordlistLoader do
  def load_from_files(file_names) do
    file_names
    |> Stream.map(fn name -> Task.async(fn -> load_task(name) end) end)
    |> Enum.map(&Task.await/1)
  end

  defp load_task(file_name) do
    File.stream!(file_name, [], :line)
    |> Enum.map(&String.strip/1)
    |> Dictionary.add_words
  end
end
