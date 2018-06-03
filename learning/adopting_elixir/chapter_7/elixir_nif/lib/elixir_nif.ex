defmodule ElixirNif do
  @moduledoc """
  A module with a simple example of using NIFs within Elixir.
  """
  @on_load :load_nif

  @doc """
  Will look for a `.so` or `.dll` file in `priv/elixir_nif`. Must return `:ok`.
  """
  @spec load_nif() :: :ok
  def load_nif do
    nif = Application.app_dir(:elixir_nif, "priv/elixir_nif")
    :ok = :erlang.load_nif(String.to_charlist(nif), 0)
  end

  @doc """
  `load_nif/0` replaces this `hello/0` function with one implemented
  in C if it is available. Otherwise raises an exception.
  """
  @spec hello() :: String.t() | no_return()
  def hello do
    raise("NIF could not be loaded")
  end
end
