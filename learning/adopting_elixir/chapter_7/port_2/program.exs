port = Port.open({:spawn, "elixir all_caps.exs"}, [:binary, packet: 4])

Port.command(port, "command without newline")

receive do
  {^port, {:data, data}} ->
    IO.puts("Got: #{data}")
end

Port.close(port)
IO.puts("Closed")
