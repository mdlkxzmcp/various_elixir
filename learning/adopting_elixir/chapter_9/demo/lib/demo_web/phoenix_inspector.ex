defmodule DemoWeb.PhoenixInspector do
  @moduledoc """
  Called by Phoenix when specific events happen due to this module being included in the `config.exs` file as one of the instrumenters.
  Should always export two functions for each event – one matching on `:start`, and another on `:stop`.
  This module can be used for further instrumentation.
  """

  @doc """
  `:start` event – includes compile time and runtime information:
    * `compile_metadata` contains:
      - `application` – name of the application ;)
      - `file` – path to the file from which the event got generated.
      - `function` – name of the function responsible for the event.
      - `line` – line number of said function.
      - `module` – name of the module.
    * `runtime_metadata` contains the `%Plug.Conn{}` struct as well as the `log_level` info.

  `:stop` event – includes the time the action took in native units as well as the result of the previous function (usually `:ok` | `:error`).
  """
  def phoenix_controller_call(:start, compile_metadata, runtime_metadata) do
    IO.inspect({:start, compile_metadata, runtime_metadata})
    :ok
  end

  def phoenix_controller_call(:stop, time_in_native_unit, result_of_start) do
    IO.inspect({:stop, time_in_native_unit, result_of_start})
  end
end
