defmodule App.DBG do
  @moduledoc """
  Conveniences and safety around Erlang's :dbg.
  """

  @doc """
  Sets up a new tracer.

  ##Example

      iex> import App.DBG
      iex> trace()
      iex> :dbg.p(App.Process, [:receive])

  """
  def tracer(limit \\ 100) do
    fun = fn
      _, ^limit ->
        :dbg.stop_clear()

      msg, n ->
        IO.inspect(msg)
        n + 1
    end

    :dbg.tracer(:process, {fun, 0})
  end
end
