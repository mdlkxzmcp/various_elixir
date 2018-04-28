defmodule Basic do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  # Callbacks.
  def handle_call({:some_call}, _from, state) do
    IO.puts("I handle GenServer calls")
    {:reply, state, state}
  end

  def handle_cast({:some_cast}, state) do
    IO.puts("I handle GenServer casts")
    {:noreply, state}
  end

  def handle_info({:some_info}, state) do
    IO.puts("I handle messages from other places")
    {:noreply, state}
  end
end
