port = Port.open({:spawn, "elixir all_caps.exs"}, [:binary])

send(port, {self(), {:command, "hello\n"}})

receive do
  {^port, {:data, data}} ->
    IO.puts("Got: #{data}")
end

send(port, {self(), :close})

receive do
  {^port, :closed} ->
    IO.puts("Closed")
end
