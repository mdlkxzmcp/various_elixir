for length_binary <- IO.stream(:stdio, 4) do
  <<length::32>> = length_binary
  all_caps = length |> IO.read() |> String.upcase()
  IO.write(<<byte_size(all_caps)::32, all_caps::binary>>)
end
