port = Port.open({:spawn, "elixir all_caps.exs"}, [:binary])

Port.command(port, "hello\n")

receive do
  {^port, {:data, data}} ->
    IO.puts("Got: #{data}")
end

Port.close(port)
IO.puts("Closed")
