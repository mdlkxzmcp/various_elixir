defmodule Sequence.Server do
  use GenServer

  #####
  # External API

  def start_link(current_number) do
    GenServer.start_link(__MODULE__, current_number, name: __MODULE__)
  end

  def next_number do
    GenServer.call __MODULE__, :next_number
  end

  def increment_number(delta) do
    GenServer.cast __MODULE__, {:increment_number, delta}
  end

  #####
  # GenServer implementation

  def handle_call(:next_number, _from, current_number) do
    { :reply, current_number, current_number + 1 }
  end

  def handle_call({:set_number, new_number}, _from, _current_number) do
    { :reply, new_number, new_number }
  end

  def handle_cast({:increment_number, delta}, current_number) do
    { :noreply, current_number + delta}
  end

  def format_status(_reason, [_pdict, state ]) do
    [data: [{'State', "My current state is '#{inspect state}'"}]]
  end

end


# Chapter 17


## Tracing a Server’s Execution

# in iex

# r Sequence.Server   # recompiles

{ :ok, pid } = GenServer.start_link(Sequence.Server, 100)
# {:ok, #PID<....>}
GenServer.call(pid, :next_number)
# 100
GenServer.call(pid, :next_number)
# 101
GenServer.cast(pid, {:increment_number, 200})
# :ok
GenServer.call(pid, :next_number)
# 302

{:ok,pid} = GenServer.start_link(Sequence.Server, 100, [debug: [:trace]])
# {:ok, #PID<....>}
GenServer.call(pid, :next_number)
# *DBG* <....> got call next_number from <....>
# *DBG* <....> sent 100 to <....>, new state 101
GenServer.cast(pid, {:increment_number, 200})
# *DBG* <....> got cast {increment_number,200}
# :ok
# *DBG* <....> new state 301

{:ok,pid} = GenServer.start_link(Sequence.Server, 100, [debug: [:statistics]])
# {:ok, #PID<0.147.0>}
GenServer.call(pid, :next_number)
# 100
GenServer.cast(pid, {:increment_number, 200})
# :ok
:sys.statistics pid, :get
# {:ok,
#  [start_time: {{2017, 7, 20}, {23, 4, 23}},
#   current_time: {{2017, 7, 20}, {23, 4, 32}}, reductions: 81, messages_in: 2,
#   messages_out: 0]}
:sys.trace pid, true
# :ok
GenServer.call(pid, :next_number)
# *DBG* <0.147.0> got call next_number from <0.129.0>
# *DBG* <0.147.0> sent 301 to <0.129.0>, new state 302
# 301
:sys.trace pid, false
# :ok
GenServer.call(pid, :next_number)
# 302
:sys.statistics pid, :get
# {:ok,
#  [start_time: {{2017, 7, 20}, {23, 4, 23}},
#   current_time: {{2017, 7, 20}, {23, 12, 44}}, reductions: 226, messages_in: 4,
#   messages_out: 0]}
:sys.get_status pid
# {:status, #PID<0.147.0>, {:module, :gen_server},
#  [["$ancestors": [#PID<0.129.0>, #PID<0.57.0>],
#    "$initial_call": {Sequence.Server, :init, 1}], :running, #PID<0.129.0>,
#   [statistics: {{{2017, 7, 20}, {23, 4, 23}}, {:reductions, 21}, 4, 0}],
#   [header: 'Status for generic server <0.147.0>',
#    data: [{'Status', :running}, {'Parent', #PID<0.129.0>},
#     {'Logged events', []}], data: [{'State', "My current state is '303'"}]]]}


## Naming a Process
{:ok, pid} = GenServer.start_link(Sequence.Server, 100, name: :seq)
# {:ok, #PID<0.111.0>}
GenServer.call(:seq, :next_number)
# 100
GenServer.call(:seq, :next_number)
# 101
:sys.get_status :seq
# {:status, #PID<0.111.0>, {:module, :gen_server},
#  [["$ancestors": [#PID<0.109.0>, #PID<0.59.0>],
#    "$initial_call": {Sequence.Server, :init, 1}], :running, #PID<0.109.0>, [],
#   [header: 'Status for generic server seq',
#    data: [{'Status', :running}, {'Parent', #PID<0.109.0>},
#     {'Logged events', []}], data: [{'State', "My current state is '102'"}]]]}
