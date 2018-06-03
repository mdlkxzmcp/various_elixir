# Generic Server
defmodule Counter do
  @moduledoc """
  A flawed implementation of a counter. Hard to debug, has no hooks for retrieving useful runtime information. Also has no way to be updated.
  """

  def start_link(initial_value) do
    {:ok, spawn_link(__MODULE__, :loop, [initial_value])}
  end

  def loop(counter) do
    receive do
      {:read, caller} ->
        send(caller, {:counter, counter})
        loop(counter)

      :bump ->
        loop(counter + 1)
    end
  end

  @doc """
  Can block the calling process if counter process dies.
  """
  def read(counter) do
    send(counter, {:read, self()})

    receive do
      {:counter, counter} -> {:ok, counter}
    end
  end

  def bump(counter) do
    send(counter, :bump)
  end
end

defmodule Counter_2 do
  @moduledoc """
  A better version, but still misses a ton of stuff that is automatically given by a `GenServer`, including mentioned hooks or debugging help.
  """
  import Counter, only: [start_link: 1, bump: 1]

  @doc """
  Only reads certain messages out of its inbox. Can cause memory leakage.
  """
  def loop(counter) do
    receive do
      {:read, {caller, ref}} ->
        send(caller, {ref, counter})
        loop(counter)

      :bump ->
        loop(counter + 1)
    end
  end

  @doc """
  Has some improvements, but the overall implementation still leaves a ton to be desired.
  """
  def read(counter, timeout \\ 5000) do
    ref = Process.monitor(counter)
    send(counter, {:read, {self(), ref}})

    receive do
      {^ref, counter} ->
        Process.demonitor(ref, [:flush])
        {:ok, counter}

      {:DOWN, ^ref, _, _, reason} ->
        exit(reason)
    after
      timeout -> exit(:timeout)
    end
  end
end

# Proper implementation of GenServer and such

defmodule PathAllocator.Server do
  @moduledoc """
  A `GenServer` implementation that works as a file system path allocator.
  Each time a temp file is needed, the server can be asked for a tmp file path.
  The server generates one and monitors the calling process. When the caller
  terminates, the server automatically removes the file.
  """
  use GenServer

  @name PathAllocator.Server

  @type allocations :: {tmp_dir, refs}
  @type tmp_dir :: binary
  @type refs :: %{required(reference()) => tmp_dir}

  @spec start_link(tmp_dir) :: GenServer.on_start()
  def start_link(tmp_dir) when is_binary(tmp_dir) do
    GenServer.start_link(__MODULE__, tmp_dir, name: @name)
  end

  def allocate do
    GenServer.call(@name, :allocate)
  end

  @spec init(tmp_dir) :: {:ok, {tmp_dir, %{}}}
  def init(tmp_dir) do
    Process.flag(:trap_exit, true)
    {:ok, {tmp_dir, %{}}}
  end

  @spec handle_call(:allocate, {pid, any}, allocations) :: {:reply, binary, allocations}
  def handle_call(:allocate, {pid, _}, {tmp_dir, refs}) do
    path = Path.join(tmp_dir, generate_random_filename())
    ref = Process.monitor(pid)
    refs = Map.put(refs, ref, path)
    {:reply, path, {tmp_dir, refs}}
  end

  @spec handle_info({:DOWN, reference(), any, any, any}, allocations) :: {:noreply, allocations}
  def handle_info({:DOWN, ref, _, _, _reason}, {tmp_dir, refs}) do
    {path, refs} = Map.pop(refs, ref)
    File.rm(path)
    {:noreply, {tmp_dir, refs}}
  end

  @spec terminate(atom, allocations) :: :ok
  def terminate(_reason, {_tmp_dir, refs}) do
    for {_, path} <- refs do
      File.rm(path)
    end

    :ok
  end

  @spec generate_random_filename() :: tmp_dir
  defp generate_random_filename do
    Base.url_encode64(:crypto.strong_rand_bytes(48))
  end
end

defmodule PathAllocator.Application do
  @spec start(any, any) :: {:ok, pid} | {:error, term}
  def start(_type, _args) do
    children = [
      {PathAllocator.Server, System.tmp_dir()}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
