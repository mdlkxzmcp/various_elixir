defmodule Sequence do
  use Application

  @initial_state Application.get_env(:sequence, :initial_state)

  def start(_type, _args) do
    {:ok, _pid} = Sequence.Supervisor.start_link(@initial_state)
  end
end
