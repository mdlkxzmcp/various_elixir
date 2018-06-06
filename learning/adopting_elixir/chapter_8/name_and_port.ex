defmodule NameAndPort do
  @moduledoc """
  A EPMD client module that doesn't invoke actual EPMD.
  Needs to be compiled first with `$ elixirc name_and_port.ex` after which
  it can be used as a replacement in this manner:
  ```
  $ iex --sname "example-9100" --erl "start_epmd false \
      -epmd_module Elixir.NameAndPort -kernel inet_dist_listen_min 9100 \
      -kernel inet_dist_listen_max 9100"
  ```
  """

  # The current distribution protocol version.
  @protocol_version 5

  @doc """
  This EPMD client does not have an underlying process, so it returns `:ignore`
  """
  @spec start_link() :: :ignore
  def start_link do
    :ignore
  end

  @doc """
  Returns a creation number from `1..3` as required by Erlang.
  """
  @spec register_name(any(), any(), any()) :: {:ok, integer}
  def register_name(_name, _port, _version) do
    {:ok, :rand.uniform(3)}
  end

  @doc """
  Retrieves the port from the node name.
  Expects `name` to be in the format of `:name-port@node`.

  Can be further simplified if ports are fixed across all nodes
  by returning {:port, PORT, @protocol_version}.

  ## Example

      iex> port_please(:sample-9100@node, 111)
      {:port, 9100, 5}

  """
  @spec port_please(atom, any) :: {:port, integer, integer} | :noport
  def port_please(name, _ip) do
    shortname = name |> to_string() |> String.split("@") |> hd()

    with [_prefix, port_string] <- String.split(shortname, "-"),
         {port, ""} <- Integer.parse(port_string) do
      {:port, port, @protocol_version}
    else
      _ -> :noport
    end
  end

  @doc """
  There are no names to be fetched since there is no EPMD.
  """
  @spec names(any()) :: {:error, :no_epmd}
  def names(_hostnames) do
    {:error, :no_epmd}
  end
end
