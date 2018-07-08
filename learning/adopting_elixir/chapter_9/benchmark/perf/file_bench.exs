defmodule FileBench do
  @moduledoc """
  A benchmarking example module with two seemingly similar implementations.
  Expects a `words.txt` file in the project directory.
  """
  @fixture "./words.txt"

  @doc """
  Executes the entire benchmark.
  """
  def run do
    Benchee.run(
      %{
        "with read" => &with_read/0,
        "with stream" => &with_stream/0
      },
      time: 10
    )
  end

  @doc """
  Provides the implementation with `File.read!/1`
  """
  def with_read do
    @fixture
    |> File.read!()
    |> String.split("\n")
    |> Enum.max_by(&String.length/1)
  end

  @doc """
  Provides the implementation with `File.stream!/1`
  """
  def with_stream do
    @fixture
    |> File.stream!()
    |> Enum.max_by(&String.length/1)
    |> String.trim()
  end
end
