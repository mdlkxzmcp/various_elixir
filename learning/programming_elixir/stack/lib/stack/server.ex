defmodule Stack.Server do
  use GenServer

  #####
  # External API

  def start_link(stash_pid) do
    {:ok, _pid} = GenServer.start_link(__MODULE__, stash_pid, name: __MODULE__)
  end

  def set(stack) do
    GenServer.call __MODULE__, {:set_stack, stack}
  end

  def pop do
    GenServer.call __MODULE__, :pop
  end

  def push(value) do
    GenServer.cast __MODULE__, {:push, value}
  end

  #####
  # GenServer implementation

  def init(stash_pid) do
    current_stack = Stack.Stash.get_stack stash_pid
    { :ok, {current_stack, stash_pid} }
  end

  def handle_call({:set_stack, stack}, _from, {_current_stack, stash_pid}) do
    { :reply, stack, {stack, stash_pid}}
  end

  def handle_call(:pop, _from, {[stack_head | stack_tail ] = _current_stack, stash_pid}) do
    { :reply, stack_head, {stack_tail, stash_pid} }
  end

  def handle_call(:pop, _from, {stack, stash_pid}) when length(stack) == 0 do
    { :stop, "The current stack is empty", {stack, stash_pid} }
  end

  def handle_cast({:push, value}, {current_stack, stash_pid}) do
    {:noreply, {[value | current_stack], stash_pid}}
  end

  def terminate(_reason, {current_stack, stash_pid}) do
    Stack.Stash.save_stack stash_pid, current_stack
  end

  def format_status(_reason, [_pdict, {stack, stash_pid} = _state ]) do
    [data: [{'State', "My current state is: stack = '#{inspect stack}', stash pid = '#{inspect stash_pid}'"}]]
  end

end
