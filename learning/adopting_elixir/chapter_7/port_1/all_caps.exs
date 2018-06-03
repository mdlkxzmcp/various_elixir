for line <- IO.stream(:stdio, :line) do
  IO.write(String.upcase(line))
end
