# Working with Multiple Processes

## A Simple Process

defmodule SpawnBasic do
  def greet do
    IO.puts "Hello"
  end
end

spawn(SpawnBasic, :greet, [])
# Hello
# #PID<....>


## Sending Messages Between Processes

defmodule Spawn1 do
  def greet do
    receive do
      {sender, msg} ->
        send sender, { :ok, "Hello, #{msg}" }
    end
  end
end

# a client
pid = spawn(Spawn1, :greet, [])
send pid, {self(), "World!"}

receive do
  {:ok, message} ->
    IO.puts message
end


## Handling Multiple Messages

defmodule Spawn2 do
  def greet do
    receive do
      {sender, msg} ->
        send sender, { :ok, "Hello, #{msg}" }
        greet()
    end
  end
end

# a client
pid = spawn(Spawn2, :greet, [])
send pid, {self(), "World!"}

receive do
  {:ok, message} ->
    IO.puts message
end

send pid, {self(), "Kermit!"}
receive do
  {:ok, message} ->
    IO.puts message
  after 500 ->
    IO.puts "The greeter has gone away :("
end


## Recursion, Looping, and the Stack
defmodule TailRecursive do
  def factorial(n),   do: _fact(n, 1)
  defp _fact(0, acc), do: acc
  defp _fact(n, acc), do: _fact(n-1, acc*n)
end


## Process Overhead

defmodule Chain do
  def counter(next_pid) do
    receive do
      n ->
        send next_pid, n + 1
    end
  end

  def create_processes(n) do
    last = Enum.reduce 1..n, self(),
            fn (_, send_to) ->
              spawn(Chain, :counter, [send_to])
            end

    send last, 0      # start the count by sending a zero to the last process

    receive do        # and wait for the result to come back to us
      final_answer when is_integer(final_answer) ->
        "Result is #{inspect(final_answer)}"
    end
  end

  def run(n) do
    IO.puts inspect :timer.tc(Chain, :create_processes, [n])
  end
end


## Exercises:

# elixir -r chapter_15.exs -e "Chain.run(10_000)"
# {5234, "Result is 1000"}          # 5ms
# elixir -r chapter_15.exs -e "Chain.run(100_000)"
# {326601, "Result is 100000"}      # 326ms
# elixir --erl "+P 1000000" -r chapter_15.exs -e "Chain.run(1_000_000)"
# {4650632, "Result is 1000000"}    # 4.6s


defmodule FredAndBetty do
  def token_play(token) do
    receive do
      {:msg, from: sender, content: senders_token} ->
        IO.puts "I am #{token} and #{senders_token} contacted me!"
        send sender, {:msg, from: self(), content: token}
    after 500 ->
      IO.puts "I am #{token} and I think I am alone..."
    end
  end

  def run do
    fred = spawn(FredAndBetty, :token_play, ["Fred"])
    betty = spawn(FredAndBetty, :token_play, ["Betty"])

    send fred, {:msg, from: betty, content: "Betty"}
  end
end

# FredAndBetty.run()

## When Processes Die

defmodule Link1 do
  import :timer, only: [ sleep: 1 ]

  def sad_function do
    sleep 500
    exit(:boom)
  end

  def run do
    spawn(Link1, :sad_function, [])
    receive do
      msg ->
        IO.puts "MESSAGE RECIEVED: #{inspect msg}"
      after 1000 ->
        IO.puts "Nothing happened as far as I am concerned"
    end
  end
end

# Link1.run


## Linking Two Processes
defmodule Link2 do
  import :timer, only: [ sleep: 1 ]

  def sad_function do
    sleep 500
    exit(:boom)
  end

  def run do
    spawn_link(Link2, :sad_function, [])
    receive do
      msg ->
        IO.puts "MESSAGE RECIEVED: #{inspect msg}"
      after 1000 ->
        IO.puts "Nothing happened as far as I am concerned"
    end
  end
end

# Link2.run

defmodule Link3 do
  import :timer, only: [ sleep: 1 ]

  def sad_function do
    sleep 500
    exit(:boom)
  end

  def run do
    Process.flag(:trap_exit, true)
    spawn_link(Link3, :sad_function, [])
    receive do
      msg ->
        IO.puts "MESSAGE RECIEVED: #{inspect msg}"
      after 1000 ->
        IO.puts "Nothing happened as far as I am concerned"
    end
  end
end

# Link3.run


## Monitoring a Process

defmodule Monitor1 do
  import :timer, only: [ sleep: 1 ]

  def sad_function do
    sleep 500
    exit(:boom)
  end

  def run do
    res = spawn_monitor(Monitor1, :sad_function, [])
    IO.puts inspect res
    receive do
      msg ->
        IO.puts "MESSAGE RECIEVED: #{inspect msg}"
    after 1000 ->
      IO.puts "Nothing happened as far as I am concerned"
    end
  end
end

# Monitor1.run


## Exercises:

defmodule ParentChild1 do
  import :timer, only: [ sleep: 1 ]

  def parent do
    Process.flag(:trap_exit, true)
    spawn_link(ParentChild1, :child, [self()])
    sleep 500
    receive_from_child()
  end

  def receive_from_child do
    receive do
      message ->
        IO.puts inspect message
        receive_from_child()
    after 1000 ->
      IO.puts "No more messages~"
    end
  end

  def child(parents_pid) do
    send parents_pid, "one"
    send parents_pid, "two"
    send parents_pid, "three"
    exit(:boom)
  end
end

# ParentChild1.parent()


defmodule ParentChild2 do
  import :timer, only: [ sleep: 1 ]

  def parent do
    Process.flag(:trap_exit, true)
    spawn_link(ParentChild2, :child, [self()])
    sleep 500
    receive_from_child()
  end

  def receive_from_child do
    receive do
      message ->
        IO.puts inspect message
        receive_from_child()
    after 1000 ->
      IO.puts "No more messages~"
    end
  end

  def child(parents_pid) do
    send parents_pid, "one"
    send parents_pid, "two"
    send parents_pid, "three"
    raise("I AM DYING UGHHHHH--")
  end
end

# ParentChild2.parent()


defmodule ParentChildMonitor1 do
  import :timer, only: [ sleep: 1 ]

  def parent do
    Process.flag(:trap_exit, true)
    spawn_monitor(ParentChildMonitor1, :child, [self()])
    sleep 500
    receive_from_child()
  end

  def receive_from_child do
    receive do
      message ->
        IO.puts inspect message
        receive_from_child()
    after 1000 ->
      IO.puts "No more messages~"
    end
  end

  def child(parents_pid) do
    send parents_pid, "one"
    send parents_pid, "two"
    send parents_pid, "three"
    exit(:boom)
  end
end

# ParentChildMonitor1.parent()


defmodule ParentChildMonitor2 do
  import :timer, only: [ sleep: 1 ]

  def parent do
    Process.flag(:trap_exit, true)
    spawn_monitor(ParentChildMonitor2, :child, [self()])
    sleep 500
    receive_from_child()
  end

  def receive_from_child do
    receive do
      message ->
        IO.puts inspect message
        receive_from_child()
    after 1000 ->
      IO.puts "No more messages~"
    end
  end

  def child(parents_pid) do
    send parents_pid, "one"
    send parents_pid, "two"
    send parents_pid, "three"
    raise("I AM DYING UGHHHHH--")
  end
end

# ParentChildMonitor2.parent()


## Parallel Map — The “Hello, World” of Erlang

defmodule Parallel do
  def pmap(collection, fun) do
    me = self()
    collection
    |> Enum.map(fn (elem) ->
        spawn_link fn -> (send me, { self(), fun.(elem) }) end
      end)
    |> Enum.map(fn (pid) ->
        receive do { ^pid, result } -> result end
      end)
  end
end

# Parallel.pmap 1..10, &(&1 * &1)


## Exercises:

# The me = self() assigment makes the spawned processes send the message to the
# process which called them, otherwise they would just send the message to themselves.

# Once the pin from pid is removed the result will stop being deterministic,
# so in case of passing in a function that requires a random time of executions
# the result will stop being in order of creation.


## A Fibonacci Server

defmodule FibSolver do

  def fib(scheduler) do
    send scheduler, { :ready, self() }
    receive do
      { :fib, n, client } ->
        send client, { :answer, n, fib_calc(n), self() }
        fib(scheduler)
      { :shutdown } ->
        exit(:normal)
    end
  end

  # very inefficient, deliberately
  defp fib_calc(0), do: 0
  defp fib_calc(1), do: 1
  defp fib_calc(n), do: fib_calc(n-1) + fib_calc(n-2)
end

defmodule Scheduler do

  def run(num_processes, module, func, to_calculate) do
    (1..num_processes)
    |> Enum.map(fn(_) -> spawn(module, func, [self()]) end)
    |> schedule_processes(to_calculate, [])
  end

  defp schedule_processes(processes, queue, results) do
    receive do
      { :ready, pid } when length(queue) > 0 ->
        [ next | tail ] = queue
        send pid, { :fib, next, self() }
        schedule_processes(processes, tail, results)

      { :ready, pid } ->
        send pid, { :shutdown }
        if length(processes) > 1 do
          schedule_processes(List.delete(processes, pid), queue, results)
        else
          Enum.sort(results, fn {n1, _}, {n2, _} -> n1 <= n2 end)
        end

      { :answer, number, result, _pid } ->
        schedule_processes(processes, queue, [ {number, result} | results ])
    end
  end
end

defmodule FibRunner do

  def run do
    to_process = List.duplicate(37, 20)

    Enum.each 1..10, fn num_processes ->
      {time, result} = :timer.tc(
        Scheduler, :run,
        [num_processes, FibSolver, :fib, to_process]
      )

      if num_processes == 1 do
        IO.puts "\nInspecting the results:\n#{inspect result}\n\n"
        IO.puts "\n #   time (s)"
      end
      :io.format "~2B     ~.2f~n", [num_processes, time/1000000.0]
    end
  end
end

# FibRunner.run()


## Exercise:

defmodule WordCounter do

  def count(scheduler) do
    send scheduler, { :ready, self() }
    receive do
      { :count, file, word, client } ->
        send client, { :answer, file, word, count_word(file, word), self() }
      { :shutdown } ->
        exit( :normal )
    end
  end

  def count_word(file, word) do
    tokens =
      File.read!(file)
      |> String.split(word)
    length(tokens) - 1
  end
end

defmodule WordScheduler do

  def run(num_processes, module, func, directory, word) do
    files =
      File.ls!(directory)
      |> Enum.map(fn file -> Path.join(directory, file) end)

    (1..num_processes)
    |> Enum.map(fn(_) -> spawn(module, func, [self()]) end)
    |> schedule_processes(files, word, Map.new())
  end

  defp schedule_processes(processes, queue, word, results) do
    receive do
      { :ready, pid } when length(queue) > 0 ->
        [ next | tail ] = queue
        send pid, { :count, next, word, self() }
        schedule_processes(processes, tail, word, results)

      { :ready, pid } ->
        send pid, { :shutdown }
        if length(processes) > 1 do
          schedule_processes(List.delete(processes, pid), queue, word, results)
        else
          results
        end

      { :answer, file, _word, result, _pid } ->
        schedule_processes(processes, queue, word, Map.put(results, file, result))
    end
  end
end

defmodule WordRunner do
  def run(directory, word) do
    Enum.each 1..10, fn num_processes ->
      {time, result} = :timer.tc(
        WordScheduler, :run, [num_processes, WordCounter, :count, directory, word])

      if num_processes == 1 do
        IO.puts "\nInspecting the results:\n#{inspect result}\n\n"
        IO.puts "\n #   time (s)"
      end
      :io.format "~2B     ~.2f~n", [num_processes, time/100000.0]
    end
  end
end


## Agents—A Teaser

defmodule FibAgent do
  def start_link do
    Agent.start_link(fn -> %{ 0 => 0, 1 => 1} end)
  end

  def fib(pid, n) when n >= 0 do
    Agent.get_and_update(pid, &do_fib(&1, n))
  end

  defp do_fib(cache, n) do
    case cache[n] do
      nil ->
        { n_1, cache } = do_fib(cache, n-1)
        result         = n_1 + cache[n-2]
        { result, Map.put(cache, n, result) }

      cached_value ->
        { cached_value , cache }
    end
  end

end

{:ok, agent} = FibAgent.start_link()
IO.puts FibAgent.fib(agent, 2000)
