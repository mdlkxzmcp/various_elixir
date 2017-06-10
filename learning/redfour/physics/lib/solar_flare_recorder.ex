defmodule SolarFlareRecorder do
  use GenServer

  def start_link do
    Agent.start_link fn -> [] end
  end

  #public API
  def record_flare(pid, {:flare, classification: _c, scale: _s} = flare) do
    Agent.get_and_update pid, fn(flares) ->
      new_state = List.insert_at flares, -1, flare
      {:ok, new_state}
    end
  end

  def get_flares(pid) do
    Agent.get pid, fn(flares) ->
      flares
    end
  end

end
