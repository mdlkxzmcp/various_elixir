IO.puts "Hello World"



# #iex:break

{:ok, dict} = File.read("words.txt")

words = dict |> String.split("\n") # list of strings

words = dict |> String.split("\n") |> Enum.map(fn word -> to_charlist word end)
# a list of charlists

tiles = Enum.shuffle('jumble')

Enum.filter(words, fn word -> Enum.all?(for c <- words, do: Enum.member?(tiles, c)) end)
# is the same as:
words |> Enum.filter(fn word -> Enum.all?(word |> Enum.map(fn c -> tiles |> Enum.member?(c) end)) end)

## Using mix to begin a new project
# $ mix new <nameoftheproject>
# $ cd <nameoftheproject>
# $ mix test

## Compiling a module
# v.1 (one time thing)
# $ iex <lib/module_name.ex>
# iex(1)> module_name.function(thing)
#
# v.2 (will be always loaded into the iex at the projects directory)
# $ elixirc <lib/module_name.ex>
# ls   # Elixir.module_name.beam

## Get mix to install your dependencies
# mix deps.get

## Generate the documentation
# mix docs
