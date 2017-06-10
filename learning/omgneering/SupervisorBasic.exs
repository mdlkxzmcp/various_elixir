defmodule BasicSupervisor do
  use Supervisor
  
  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end
  
  def init([]) do
    children = [
      worker(BasicOne, []),
      worker(BasicTwo, []),
      worker(BasicThree, []),
      worker(BasicFour, []),
    ]
    
    supervise(children, strategy: :one_for_one)
  end
end


defmodule BasicOne do
  use GenServer
  
  def start_link do
    IO.puts "BasicOne is starting"
    GenServer.start_link(__MODULE__, [])
  end
end

defmodule BasicTwo do
  use GenServer
  
  def start_link do
    IO.puts "BasicTwo is starting"
    GenServer.start_link(__MODULE__, [])
  end
end

defmodule BasicThree do
  use GenServer
  
  def start_link do
    IO.puts "BasicThree is starting"
    GenServer.start_link(__MODULE__, [])
  end
end

defmodule BasicFour do
  use GenServer
  
  def start_link do
    IO.puts "BasicFour is starting"
    GenServer.start_link(__MODULE__, [])
  end
end

# strategy: :one_for_one
{:ok, super_pid} = BasicSupervisor.start_link
Process.alive?(super_pid)
[four, three, two, one] = Supervisor.which_children(super_pid)
{_, one_pid, _, _} = one
GenServer.stop(one_pid)
Process.alive?(one_pid)  # false, other ones are still alive
  # strategy: :one_for_all stops all 

# strategy: :rest_for_one
{:ok, super_pid} = BasicSupervisor.start_link
Process.alive?(super_pid)
[four, three, two, one] = Supervisor.which_children(super_pid)
{_, two_pid, _, _} = two
GenServer.stop(two_pid) # two, three, and four will be stopped


# worker(BasicOne, [], restart:           )
#                               :permanent - always restarts
#                               :transient - restarts when crashed
#                               :temporary - never restarts
