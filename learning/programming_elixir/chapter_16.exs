# Nodes — The Key to Distributing Services

## Naming Nodes

# iex(node_one@machine_name)> Node.list
# []
# iex(node_two@machine_name)> Node.list
# []
# iex(node_one@machine_name)> Node.connect :"node_two@machine_name"
# true
# iex(node_one@machine_name)> Node.list
# [:"node_two@machine_name"]
# iex(node_two@machine_name)> Node.list
# [:"node_one@machine_name"]

# iex(node_one@machine_name)> func = fn -> IO.inspect Node.self end
# iex(node_one@machine_name)> spawn(func)
# PID<....>
# node_one@machine_name
# iex(node_one@machine_name)> Node.spawn(:"node_two@machine_name", func)
# PID<....>
# node_two@machine_name


## Nodes, Cookies, and Security

# iex --sname node_one --cookie butter
# iex(node_one@machine_name)> Node.get_cookie
# :butter
# iex --sname node_two --cookie margarine
# iex(node_two@machine_name)> Node.connect :"node_one@machine_name"
# false
# iex(node_one@machine_name)>
# [error] ** Connection attempt from disallowed node :"node_two@machine_name" **


## Naming Your Processes

defmodule Ticker do

  @interval 2000   # 2 seconds
  @name     :ticker

  def start do
    pid = spawn(__MODULE__, :generator, [[]])
    :global.register_name(@name, pid)
  end

  def register(client_pid) do
    send :global.whereis_name(@name), { :register, client_pid }
  end

  def generator(clients) do
    receive do
      { :register, pid } ->
        IO.puts "registering #{inspect pid}"
        generator([ pid | clients ])
    after @interval ->
      IO.puts "tick"
      Enum.each(clients, fn client ->
        send client, { :tick }
      end)
      generator(clients)
    end
  end

end

defmodule Client do

  def start do
    pid = spawn(__MODULE__, :receiver, [])
    Ticker.register(pid)
  end

  def receiver do
    receive do
      { :tick } ->
        IO.puts "tock in client"
        receiver()
    end
  end
end


## Exercise:

defmodule Ticker2 do

  @interval 2000
  @name     :ticker_2

  def start do
    pid = spawn(__MODULE__, :generator, [[], []])
    :global.register_name(@name, pid)
  end

  def register(client_pid) do
    send :global.whereis_name(@name), { :register, client_pid }
  end


  def generator(clients, [ current | tail ] = wait_list) when length(wait_list) > 0 do
    receive do
      { :register, pid } ->
        IO.puts "registering #{inspect pid}"
        generator([ pid | clients ], wait_list)
    after @interval ->
      IO.puts "tick"
      send current, { :tick }
      generator(clients, tail)
    end
  end

  def generator(clients, []) do
    generator(clients, clients)
  end

end


## I/O, PIDs, and Nodes

# iex(two@machine_name)> Node.connect(:"one@machine_name")
# true
# iex(two@machine_name)> :global.register_name(:two, :erlang.group_leader)
# :yes
# iex(one@machine_name)> two = :global.whereis_name :two
# PID<....>
# iex(one@machine_name)> IO.puts(two, "Hello World!")
# :ok
# iex(two@machine_name)>
# Hello World!


## Exercise:

# not tested, I think there might be some problems here though.
defmodule Ring do

  @interval 2000
  @name   :ring

  def start do
    pid = spawn(__MODULE__, :request_handler, [[]])
    :global.register_name(@name, pid)
  end

  def join(client_pid) do
    send :global.whereis_name(@name), { :join, client_pid }
  end

  def leave(client_pid) do
    send :global.whereis_name(@name), { :leave, client_pid }
  end

  def request_handler(clients) do
    receive do
      { :join, pid } ->
        clients = update_clients_list(clients, pid, :add)
        IO.puts "Client #{inspect pid} has joined the #{@name}"

        IO.puts "Updating clients links..."
        update_clients_links(clients)

        request_handler(clients)

      { :leave, pid } ->
        clients = update_clients_list(clients, pid, :remove)
        IO.puts "Client #{inspect pid} has left the #{@name}"

        IO.puts "Updating clients links..."
        update_clients_links(clients)

        request_handler(clients)

      { :tick } ->
        send List.first(clients), { :tick }
        request_handler(clients)
    after @interval ->
      send self(), { :tick }
      request_handler(clients)
    end
  end

  defp update_clients_list(clients, pid, action) do
    case action do
      :delete ->
        List.delete(clients, pid)
      :add ->
        clients ++ [pid]
    end
  end

  defp update_clients_links(clients) do
    case clients do
      [ client | other_clients ] ->
        next_client = List.first(other_clients)
        send client, { :update_link, next_client }
        update_clients_links(other_clients)
      [] ->
        IO.puts "Clients links updated."
    end
  end
end

defmodule RingClient do

  def run do
    Process.flag(:trap_exit, true)
    pid = spawn_link(__MODULE__, :receiver, [[]])
    Ring.join(pid)
    receive do
      { :EXIT, pid, _reason } ->
        Ring.leave(pid)
    end
  end

  def receiver(client) do
    receive do
      { :update_link, next_client } ->
        receiver(next_client)
      { :tick } ->
        IO.puts "Tick in client #{inspect self()}"
        send_tick(client)
        receiver(client)
    end
  end

  defp send_tick(client) when is_pid(client) do
    send client, { :tick }
  end

  defp send_tick([]) do
    IO.puts "There are no other clients that I know..."
  end
end
