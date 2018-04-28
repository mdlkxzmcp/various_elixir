defmodule BasicSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = [
      worker(BasicOne, [])
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end

defmodule BasicOne do
  use GenServer

  def start_link do
    IO.puts("BasicOne is starting")
    GenServer.start_link(__MODULE__, [])
  end
end

{:ok, super_pid} = BasicSupervisor.start_link()
# []
Supervisor.which_children(super_pid)
# IO.puts // PID xxx
Supervisor.start_child(super_pid, [])
# IO.puts // PID yyy
Supervisor.start_child(super_pid, [])
[basic_a, _basic_b] = Supervisor.which_children(super_pid)
{_, basic_a_pid, _, _} = basic_a
Supervisor.terminate_child(super_pid, basic_a_pid)
