defmodule Formatter do
  @type level :: :debug | :info | :warn | :error
  @type message :: IO.chardata() | String.Chars.t()
  @type time :: term()
  @type metadata :: keyword(String.Chars.t())
  @type json :: iodata | no_return

  @doc """
  Transforms a typical `Logger` message to JSON.
  """
  @spec json_formatter(level, message, time, metadata) :: json()
  def json_formatter(level, message, time, metadata) do
    message = IO.chardata_to_string(message)
    [encode_to_json(level, message, time, Map.new(metadata)), ?\n]
  end

  defp encode_to_json(level, message, _time, metadata) do
    Poison.encode!(%{
      level: level,
      message: message,
      metadata: metadata
    })
  rescue
    _ ->
      Poison.encode!(%{
        level: level,
        message: "error while formatting #{inspect(message)} with #{inspect(metadata)}",
        metadata: %{}
      })
  end
end
