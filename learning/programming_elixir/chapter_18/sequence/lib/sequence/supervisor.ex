defmodule Sequence.Supervisor do
  use Supervisor

  def start_link(initial_state) do
    result = {:ok, sup} = Supervisor.start_link(__MODULE__, [initial_state])
    start_workers(sup, initial_state)
    result
  end

  def start_workers(sup, initial_state) do
    {:ok, stash} =
      Supervisor.start_child(sup, worker(Sequence.Stash, [initial_state]))
    Supervisor.start_child(sup, supervisor(Sequence.SubSupervisor, [stash]))
  end

  def init(_) do
    supervise [], strategy: :one_for_one
  end

end
