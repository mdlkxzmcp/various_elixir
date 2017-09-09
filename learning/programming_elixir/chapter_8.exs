# Maps, Keyword Lists, Sets, and Structs


## Keyword Lists

defmodule Canvas do
  @defaults [ fg: "black", bg: "white", font: "Merriweather" ]

  def draw_text(text, options \\ []) do
    options = Keyword.merge(@defaults, options)
    IO.puts "Drawing text #{inspect(text)}"
    IO.puts "Foreground:  #{options[:fg]}"
    IO.puts "Background:  #{Keyword.get(options, :bg)}"
    IO.puts "Font:        #{Keyword.get(options, :font)}"
    IO.puts "Pattern:     #{Keyword.get(options, :pattern, "solid")}"
    IO.puts "Style:       #{inspect Keyword.get_values(options, :style)}"
  end

end

Canvas.draw_text("Howdy stranger.", fg: "purple", style: "wicked")


## Maps

map = %{ name: "Max", likes: "Music", where: "Poland" }
Map.keys map
Map.values map
map[:name]
map.name
mapl = Map.drop map, [:where, :likes]
map2 = Map.put map, :also_likes, "Programming"
Map.keys map2
Map.has_key? mapl, :where
{ _value, updated_map } = Map.pop map2, :also_likes
Map.equal? map, updated_map


## Pattern Matching and Updating Maps

defmodule HotelRoom do

  def book(%{name: name, height: height}) when height > 1.9 do
    IO.puts "Need extra long bed for #{name}"
  end

  def book(%{name: name, height: height}) when height < 1.3 do
    IO.puts "Need low shower controls for #{name}"
  end

  def book(person) do
    IO.puts "Need regular bed for #{person.name}"
  end

end

people = [
  %{ name: "Grumpy", height: 1.24 },
  %{ name: "Dave", height: 1.88 },
  %{ name: "Dopey", height: 1.32 },
  %{ name: "Shaquille", height: 2.16 },
  %{ name: "Sneezy", height: 1.28 },
  %{ name: "Max", height: 1.93 }
  ]

IO.inspect(for person = %{ height: height } <- people, height > 1.6, do: person)

people |> Enum.each(&HotelRoom.book/1)


## Pattern Matching Can Match Variable Keys

data = %{ name: "Max", likes: "Elixir", where: "Poland" }
for key <- [:name, :likes] do
  %{ ^key => value } = data
  value
end


## Updating a Map

m = %{ a: 1, b: 2, c: 3 }
m1 = %{ m | b: "two", c: "three" }
m2 = %{ m1 | a: "one" }
Map.put_new(m2, :d, "four")


## Structs

defmodule Subscriber do
  defstruct name: "", paid: false, over_18: true
end

# s1 = %Subscriber{}
# s2 = %Subscriber{ name: "Dave" }
# s3 = %Subscriber{ name: "Mary", paid: true }
# s4 = %Subscriber{ s3 | name: "Marie"}
#
# %Subscriber{name: a_name} = s3
# a_name


defmodule Attendee do
  defstruct name: "", paid: false, over_18: true

  def may_attend_after_party(attendee = %Attendee{}) do
    attendee.paid && attendee.over_18
  end

  def print_vip_badge(%Attendee{name: name}) when name != "" do
    IO.puts "Very cheap badge for #{name}"
  end
  def print_vip_badge(%Attendee{}) do
    raise "missing name for badge"
  end

end

# a1 = %Attendee{name: "Dave", over_18: true}
# Attendee.may_attend_after_party(a1)
# a2 = %Attendee{a1 | paid: true}
# Attendee.may_attend_after_party(a2)
# Attendee.print_vip_badge(a2)
# a3 = %Attendee{}
# Attendee.print_vip_badge(a3)


## Nested Dictionary Structures

defmodule Customer do
  defstruct name: "", company: ""
end

defmodule BugReport do
  defstruct owner: %Customer{}, details: "", severity: 1
end

# report = %BugReport{owner: %Customer{name: "Dave", company: "Pragmatic"}, details: "broken"}
# report.owner.company
# report = %BugReport{ report | owner: %Customer{ report.owner | company: "PragProg" }}
# put_in(report.owner.company, "PragProg")
# update_in(report.owner.name, &("Mr. " <> &1))


## Nested Accessors and Nonstructs
# report = %{ owner: %{ name: "Dave", company: "Pragmatic" }, severity: 1}
# put_in(report[:owner][:company], "PragProg")
# update_in(report[:owner][:name], &("Mr. " <> &1))


## Dynamic (Runtime) Nested Accessors

nested = %{
  buttercup: %{
    actor: %{
      first: "Robin",
      last: "Wright"
    },
    role: "princess"
  },
  westley: %{
    actor: %{
      first: "Cary",
      last: "Ewles"
    },
    role: "farm boy"
  }
}

IO.inspect get_in(nested, [:buttercup])
IO.inspect get_in(nested, [:buttercup, :actor])
IO.inspect get_in(nested, [:buttercup, :actor, :first])
IO.inspect put_in(nested, [:westley, :actor, :last], "Elwes")


authors = [
  %{ name: "José", language: "Elixir" },
  %{ name: "Matz", language: "Ruby" },
  %{ name: "Larry", language: "Perl" }
]

languages_with_an_r = fn (:get, collection, next_fn) ->
  for row <- collection do
    if String.contains?(row.language, "r") do
      next_fn.(row)
    end
  end
end

IO.inspect get_in(authors, [languages_with_an_r, :name])


## The Access Module

cast = [
  %{
    character: "Buttercup",
    actor: %{
      first: "Robin",
      last: "Wright"
    },
    role: "princess"
  },
  %{
    character: "Westley",
    actor: %{
      first: "Cary",
      last: "Elwes"
    },
    role: "farm boy"
  }
]

IO.inspect get_in(cast, [Access.all(), :character])
IO.inspect get_in(cast, [Access.at(1), :role])
IO.inspect get_and_update_in(cast, [Access.all(), :actor, :last], fn (val) -> {val, String.upcase(val)} end)

cast2 = [
  %{
    character: "Buttercup",
    actor: {"Robin", "Wright"},
    role: "princess"
  },
  %{
    character: "Westley",
    actor: {"Carey", "Elwes"},
    role: "farm boy"
  }
]

IO.inspect get_in(cast2, [Access.all(), :actor, Access.elem(1)])
IO.inspect get_and_update_in(cast2, [Access.all(), :actor, Access.elem(1)], fn (val) -> {val, String.reverse(val)} end)

cast3 = %{
  buttercup: %{
    actor: {"Robin", "Wright"},
    role: "princess"
  },
  westley: %{
    actor: {"Carey", "Elwes"},
    role: "farm boy"
  }
}

IO.inspect get_in(cast3, [Access.key!(:westley), :actor, Access.elem(1)])
IO.inspect get_and_update_in(cast3, [Access.key!(:buttercup), :role], fn (val) -> {val, "Queen"} end)

Access.pop(%{name: "Elixir", creator: "Valim"}, :name)
Access.pop([name: "Elixir", creator: "Valim"], :name)
Access.pop(%{name: "Elixir", creator: "Valim"}, :year)


# Sets
set1 = 1..5 |> Enum.into(MapSet.new)
set2 = 3..8 |> Enum.into(MapSet.new)
MapSet.member? set1, 3
MapSet.union set1, set2
MapSet.difference set1, set2
MapSet.difference set2, set1
MapSet.intersection set2, set1
