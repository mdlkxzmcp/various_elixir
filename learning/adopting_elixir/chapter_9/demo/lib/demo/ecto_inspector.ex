defmodule Demo.EctoInspector do
  @moduledoc """
  Called by Ecto due to this module being included in the `confix.exs` file as one of the loggers.
  This module can be used for further instrumentation.
  """

  @doc """
  When for example `/posts` is accesed, prints an `%Ecto.LogEntry{}` struct containing various useful information such as:
    * `:query_time` – amount of time the query took to execute, reported by the database. If too high, the query might need to change, an index has to be added, and/or the database needs to be optimized.
    * `:queue_time` – amount of time spent retrieving the database connection from the pool. It's a capacity problem if this is too high. Either the load is too great, or the pool is too small.
    * `:decode_time` – amount of time spent converting the results into Elixir data structures. Custom decoding functions may cause problems here, such as those defined in custom `Ecto.Types`.

  All measurements are displayed in native units.
  """
  @spec log(Ecto.LogEntry.t()) :: Ecto.LogEntry.t()
  def log(log) do
    IO.inspect(log)
    log
  end
end
