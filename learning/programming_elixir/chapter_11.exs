# Strings and Binaries

## String Literals

name = "dave"
"Hello, #{String.capitalize name}!"


## Heredocs

IO.puts "start"
IO.write "
    my
    string
"
IO.puts "end"
# start
#
#     my
#     string
# end

IO.puts "start"
IO.write """
my
string
"""
IO.puts "end"
# start
# my
# string
# end


## Sigils

~C[1\n2#{1+2}]
# '1\\n2\#{1+2}'
~c"1\n2#{1+2}"
# '1\n23'
~S[1\n2#{1+2}]
# "1\\n2\#{1+2}"
~s/1\n2#{1+2}/
# "1\n23"
~W[the c#{'a'}t sat on the mat]
# ["the", "c\#{'a'}t", "sat", "on", "the", "mat"]
~w[the c#{'a'}t sat on the mat]
# ["the", "cat", "sat", "on", "the", "mat"]
~D<1999-12-31>
# ~D[1999-12-31]
~T[12:34:56]
# ~T[12:34:56]
~N{1999-12-31 23:59:59}
# ~N[1999-12-31 23:59:59]

~w[the c#{'a'}t sat on the mat]a
# [:the, :cat, :sat, :on, :the, :mat]
~w[the c#{'a'}t sat on the mat]c
# ['the', 'cat', 'sat', 'on', 'the', 'mat']
~w[the c#{'a'}t sat on the mat]s
# ["the", "cat", "sat", "on", "the", "mat"]

~w"""
the
cat
sat
"""
# ["the", "cat", "sat"]
~r"""
hello
"""i
# ~r/hello\n/i


## Single-Quoted Strings—Lists of Character Codes

str = 'wombat'      # 'wombat'
is_list str         # true
length str          # 6
Enum.reverse str    # 'tabmow'

[ 67, 65, 84 ]
# 'CAT'
:io.format "~w~n", [ str ]  # ~w in `format` forces str to be written as an Erlang term
# [119,111,109,98,97,116]
# :ok
List.to_tuple str
# {119, 111, 109, 98, 97, 116}
str ++ [0]
# [119, 111, 109, 98, 97, 116, 0]
'∂x/∂y'
# [8706, 120, 47, 8706, 121]

'pole' ++ 'vault'
# 'polevault'
'pole' -- 'vault'
# 'poe'
List.zip [ 'abc', '123' ]
# [{97, 49}, {98, 50}, {99, 51}]
[ head | tail ] = 'cat'
head
# 99
tail
# 'at'
[ head | tail ]
# 'cat'

defmodule Parse do

  def number([ ?- | tail ]), do: _number_digits(tail, 0) * -1
  def number([ ?+ | tail ]), do: _number_digits(tail, 0)
  def number(str),           do: _number_digits(str,  0)

  defp _number_digits([], value), do: value
  defp _number_digits([ digit | tail ], value) when digit in '0123456789' do
    _number_digits(tail, value*10 + digit - ?0)
  end
  defp _number_digits([ non_digit | _ ], _) do
    raise "Invalid digit '#{[non_digit]}'"
  end
end

Parse.number('123')
# 123
Parse.number('-123')
# -123
Parse.number('+123')
# 123
Parse.number('+9')
# 9
Parse.number('+a')
# ** (RuntimeError) Invalid digit 'a'


## Exersise:

def printable?(string), do: _printable?(string)

defp _printable?([head | tail]) when head > 31 and head < 127, do: _printable?(tail)
defp _printable?([head | _tail]) when head < 32 or head > 126, do: false
defp _printable?([]), do: true


def anagram?(word1, word2) when is_list(word1) and is_list(word2) do
  if length(word1) == length(word2)
  _anagram_checker(word1, word2)
  else
    false
end

defp _anagram_checker([], word2), do: true
defp _anagram_checker([char | tail], word2) when char in word2 do
    _anagram_checker(tail, word2)
end
defp _anagram_checker(_word1, _word2), do: false


def calculate(equation) when is_list(equation) do
  [ num1_string, operator_string, num2_string ] =
    List.to_string(equation)
    |> String.split(" ")

  {num1, _} = Float.parse(num1_string)
  {num2, _} = Float.parse(num2_string)
  case operator_string do
    "+" -> num1 + num2
    "-" -> num1 - num2
    "*" -> num1 * num2
    "/" -> num1 / num2
  end
end


## Binaries

b = << 1, 2, 3 >>
# <<1, 2, 3>>
byte_size(b)
# 3
bit_size(b)
# 24

b = << 1::size(2), 1::size(3) >>    # 01 001
# <<9::size(5)>>                    # = 9 (base 10)
byte_size b
# 1
bit_size b
# 5

int = << 1 >>
# <<1>>
float = << 2.5 :: float >>
# <<64, 4, 0, 0, 0, 0, 0, 0>>
mix = << int :: binary, float :: binary >>
# <<1, 64, 4, 0, 0, 0, 0, 0, 0>>
<< sign::size(1), exp::size(11), mantissa::size(52) >> = << 3.14159::float >>
(1 + mantissa / :math.pow(2, 52)) * :math.pow(2, exp-1023)
# 3.14159


## Double-Quoted Strings Are Binaries

dqs = "∂x/∂y"
# "∂x/∂y"
String.length dqs
# 5
byte_size dqs
# 9
String.at(dqs, 0)
# "∂"
String.codepoints(dqs)
# ["∂", "x", "/", "∂", "y"]
String.split(dqs, "/")
# ["∂x", "∂y"]


## Strings and Elixir Libraries

String.at("∂og", 0)
# "∂"
String.at("∂og", -1)
# "g"
String.capitalize "école"
# "École"
String.capitalize "ÎÎÎÎÎ"
# "Îîîîî"
String.upcase "José Ørstüd"
# "JOSÉ ØRSTÜD"
String.codepoints("José's ∂øg")
# ["J", "o", "s", "é", "'", "s", " ", "∂", "ø", "g"]
String.downcase "ØRSteD"
# "ørsted"
String.duplicate "Ho! ", 3
# "Ho! Ho! Ho! "
String.starts_with? "string", ["elix", "stri", "ring"]
# true
String.ends_with? "string", ["elix", "stri", "ring"]
# true
String.first "∂og"
# "∂"
String.last "∂og"
# "g"
String.codepoints "noe\u0308l"
# ["n", "o", "e", " ̈", "l"]
String.graphemes "noe\u0308l"
# ["n", "o", "ë", "l"]         note - the e is different here
String.jaro_distance("jonathan", "jonathon")
# 0.9166666666666666
String.jaro_distance("josé", "john")
# 0.6666666666666666
String.length "∂x/∂y"
# 5
String.myers_difference("banana", "panama")
# [del: "b", ins: "p", eq: "ana", del: "n", ins: "m", eq: "a"]

defmodule MyString do

  def each(str, func), do: _each(String.next_codepoint(str), func)

  defp _each({codepoint, rest}, func) do
    func.(codepoint)
    _each(String.next_codepoint(rest), func)
  end

  defp _each(nil, _), do: []
end

MyString.each "∂og", fn c -> IO.puts c end
# ∂
# o
# g

String.pad_leading("cat", 5, ?>)
# ">>cat"
String.pad_trailing("cat", 5)
# "cat  "
String.trim "\t Hello \r\n"
# "Hello"
String.trim "!!!SALE!!!", "!"
# "SALE"
String.trim_leading "\t\f Hello\t\n"
# "Hello\t\n"
String.trim_leading "!!!SALE!!!", "!"
# "SALE!!!"
String.trim_trailing(" line \r\n")
# " line"
String.trim_trailing "!!!SALE!!!", "!"
# "!!!SALE"
String.printable? "José"
# true
String.printable? "\x{0000} a null"
# false
String.valid? "∂"
# true
String.valid? "∂og"
# false
String.replace "the cat
on the mat", "at", "AT"
# "the cAT on the mAT"
String.replace "the cat
 on the mat", "at", "AT", global: false
# "the cAT on the mat"
String.replace "the cat
 on the mat", "at", "AT", insert_replaced: 0
# "the catAT on the matAT"
String.replace "the cat
on the mat", "at", "AT", insert_replaced: [0,2]
# "the catATat on the matATat"
String.reverse "pupils"
# "slipup"
String.reverse "∑ƒ÷∂"
# "∂÷ƒ∑"
String.slice "the cat on the mat", 4, 3
# "cat"
String.slice "the cat on the mat", -3, 3
# "mat"
String.split " the cat on the mat "
# ["the", "cat", "on", "the", "mat"]
String.split "the cat on the mat", "t"
# ["", "he ca", " on ", "he ma", ""]
String.split "the cat on the mat", ~r{[ae]}
# ["th", " c", "t on th", " m", "t"]
String.split "the cat on the mat", ~r{[ae]}, parts: 2
# ["th", " cat on the mat"]


## Exersise:

def center(words) when is_list(words) do
  width = Enum.max_by(words, &(String.length(&1)))
  |> String.length

  Enum.each(words, fn word -> _center(word, width) end)
end

defp _center(word, width) do
  difference_in_length = width - String.length(word)
  padding = String.duplicate(" ", div(difference_in_length, 2))
  IO.puts "#{padding}#{string}"
end


## Binaries and Pattern Matching

defmodule Utf8 do

  def each(str, func) when is_binary(str), do: _each(str, func)

  defp _each(<<>>, _func), do: []
  defp _each(<< head :: utf8, tail :: binary >>, func) do
    func.(head)
    _each(tail, func)
  end
end
Utf8.each "∂og", fn char -> IO.puts char end
# 8706
# 111
# 103


## Excercises:

def capitalize_sentences(sentence) when is_bitstring(sentence) do
  String.split(sentence, ". ")
  |> Enum.map(&String.capitalize(&1))
  |> Enum.join(". ")
end

defmodule TaxThis do

  def calculate_taxes_from_csv(filepath) when is_bitstring(filepath) do
    File.stream!(filepath)
    |> Stream.drop(1)
    |> Stream.each(&format_line(&1))
    |> Stream.each(&into_keyword_list(&1))
    |> Stream.each(&sales_tax(&1, get_tax_rates()))
    |> Enum.into([])
  end

  defp format_line(line) do
    line
    |> String.replace("\n", "")
    |> String.replace(":", "")
    |> String.split(",")
  end

  defp into_keyword_list([id, ship_to, net_amount]) do
    id = String.to_integer(id)
    ship_to = String.to_atom(place)
    net_amount = String.to_float(net_amount)
    [id: id, ship_to: ship_to, net_amount: net_amount]
  end

  defp sales_tax(order, tax_rates) do
    case tax_rates[order[:ship_to]] do
      nil ->
        order  ++ [total_amount: order[:net_amount]]
      tax_rate ->
        order  ++ [total_amount: order[:net_amount] + (order[:net_amount] * tax_rate)]
    end
  end

  defp get_tax_rates do
    [NC: 0.075, TX: 0.08]
  end
end
