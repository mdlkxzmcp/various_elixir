defmodule Stack do
  use Application

  @initial_stack Application.get_env(:stack, :initial_stack)

  def start(_type, _args) do
    {:ok, _pid} = Stack.Supervisor.start_link(@initial_stack)
  end
end
