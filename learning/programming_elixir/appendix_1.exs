# Exceptions: raise and try, catch and throw


## Raising an Exception

defmodule Boom do
  def start(n) do
    try do
      raise_error(n)
    rescue
      [ FunctionClauseError, RuntimeError ] ->
        IO.puts "no function match or runtime error"
      error in [ArithmeticError] ->
        IO.inspect error
        IO.puts "Uh-oh! Arithmetic error"
        reraise "too late, we're doomed", System.stacktrace
      other_errors ->
        IO.puts "Disaster! #{inspect other_errors}"
    after
      IO.puts "DONE!"
    end
  end

  defp raise_error(0) do
    IO.puts "No error"
  end

  defp raise_error(val = 1) do
    IO.puts "About to divide by zero"
    1 / (val-1)
  end

  defp raise_error(2) do
    IO.puts "About to call a function that doesn't exist"
    raise_error(99)
  end

  defp raise_error(3) do
    IO.puts "About to try creating a directory with no permission"
    File.mkdir!("/not_allowed")
  end
end


## catch, exit, and throw

defmodule Catch do
  def start(n) do
    try do
      incite(n)
    catch
      :exit, code   -> "Exited with code #{inspect code}"
      :throw, value -> "throw called with #{inspect value}"
      what, value   -> "Caught #{inspect what} with #{inspect value}"
    end
  end

  defp incite(1) do
    exit(:something_bad_happened)
  end

  defp incite(2) do
    throw {:animal, "wombat"}
  end

  defp incite(3) do
    :erlang.error "Oh no!"
  end
end


## Defining Your Own Exceptions

defmodule KinectProtocolError do

  defexception message: "Kinect protocol error",
               can_retry: false

  def full_message(me) do
    "Kinect failed: #{me.message}, retriable: #{me.can_retry}"
  end
end
