# Macros and Code Evaluation

## Implementing an if Statement

defmodule MyIf do
  def myif(condition, clauses) do
    do_clause = Keyword.get(clauses, :do, nil)
    else_clause = Keyword.get(clauses, :else, nil)

    case condition do
      val when val in [false, nil]
        -> else_clause
      _otherwise
        -> do_clause
    end
  end
end

MyIf.myif 1==2, do: (IO.puts "1 == 2"), else: (IO.puts "1 != 2")
# 1 == 2
# 1 != 2


## Macros Inject Code

defmodule My do
  defmacro macro(param) do
    IO.inspect param
  end
end

defmodule Test do
  require My

  # These values represent themselves
  My.macro :atom      #=> :atom
  My.macro 1          #=> 1
  My.macro 1.0        #=> 1.0
  My.macro [1,2,3]    #=> [1,2,3]
  My.macro "binaries" #=> "binaries"
  My.macro { 1, 2 }   #=> {1,2}
  My.macro do: 1      #=> [do: 1]

  # And these are represented by 3-element tuples

  My.macro { 1,2,3,4,5 }
  # => {:{}, [line: 46], [1, 2, 3, 4, 5]}

  My.macro do: ( a = 1; a+a )
  #=>   [do:
  #      {:__block__, [],
  #        [{:=, [line: 49], [{:a, [line: 49], nil, 1]},
  #         {:+, [line: 49], [{:a, [line: 49], nil, {:a, [line: 49], nil}]}]}]

  My.macro do
    1+2
  else
    3+4
  end
  #=>   [do: {:+, [line: 56], [1, 2]},
  #      else: {:+, [line: 58], [3, 4]}]
end


## The quote Function

quote do: :atom      #=> :atom
quote do: 1          #=> 1
quote do: 1.0        #=> 1.0
quote do: [1,2,3]    #=> [1,2,3]
quote do: "binaries" #=> "binaries"
quote do: { 1, 2 }   #=> {1,2}
quote do: [do: 1]    #=> [do: 1]
quote do: { 1,2,3,4,5 }
# => {:{}, [], [1, 2, 3, 4, 5]}
quote do: (a = 1; a + a)
#=>  {:__block__, [],
#     [{:=, [], [{:a, [], Elixir}, 1]},
#      {:+, [context: Elixir, import: Kernel],
#       [{:a, [], Elixir}, {:a, [], Elixir}]}]}
quote do: [do: 1 + 2, else: 3 + 4]
#=>  [do: {:+, [context: Elixir, import: Kernel], [1, 2]},
#     else: {:+, [context: Elixir, import: Kernel], [3, 4]}]


## Using the Representation As Code

defmodule My2 do
  defmacro macro(code) do
    IO.inspect code
    code
  end
end

defmodule Test2 do
  require My2
  My2.macro(IO.puts("hello"))
  #  {{:., [line: 97], [{:__aliases__, [counter: 0, line: 97], [:IO]}, :puts]},
  #   [line: 97], ["hello"]}
  # hello
end


defmodule My3 do
  defmacro macro(code) do
    IO.inspect code
    quote do: IO.puts "Different thing"  # this also works without 'quote do:'
  end
end

defmodule Test3 do
  require My3
  My3.macro(IO.puts("hello"))
  #  {{:., [line: 97], [{:__aliases__, [counter: 0, line: 97], [:IO]}, :puts]},
  #   [line: 97], ["hello"]}
  # hello
end


## The unquote Function

defmodule My4 do
  defmacro macro(_code) do
    quote do
      IO.inspect(code)  # undefined function code/0
    end
  end
end

defmodule My5 do
  defmacro macro(code) do
    quote do
      IO.inspect(unquote(code))
    end
  end
end


## Expanding a List—unquote_splicing

Code.eval_quoted(quote do: [1, 2, unquote([3,4])])
# {[1, 2, [3, 4]], []}
Code.eval_quoted(quote do: [1, 2, unquote_splicing([3,4])])
# {[1, 2, 3, 4], []}
Code.eval_quoted(quote do: [?a, ?=, unquote_splicing('1234')])
# {'a=1234', []}


## Back to myif Macro

defmodule My6 do
  defmacro if(condition, clauses) do
    do_clause   = Keyword.get(clauses, :do, nil)
    else_clause = Keyword.get(clauses, :else, nil)
    quote do
      case unquote(condition) do
        val when val in [false, nil] -> unquote(else_clause)
        _                            -> unquote(do_clause)
      end
    end
  end
end

defmodule Test6 do
  require My6

  My6.if 1==2 do
    IO.puts "1 == 2"
  else
    IO.puts "1 != 2"
  end
end


## Exercises:

defmodule MyMacro do
  defmacro myunless(condition, clauses) do
    do_clause   = Keyword.get(clauses, :do, nil)
    else_clause = Keyword.get(clauses, :else, nil)
    quote do
      if unquote(condition) != true do
        unquote(do_clause)
      else
        unquote(else_clause)
      end
    end
  end
end

defmodule MyTest1 do
  require MyMacro

  MyMacro.myunless 1==1 do
    IO.puts "1 != 1"
  else
    IO.puts "1 == 1"
  end
end

defmodule Times do
  defmacro times_n(number) do
    times_n = String.to_atom("times_#{number}")
    quote bind_quoted: [number: number, times_n: times_n] do
      def unquote(times_n)(num), do: unquote(number) * num
    end
  end
end

defmodule MyTest2 do
  require Times

  Times.times_n(3)
  Times.times_n(4)
end

IO.puts MyTest2.times_3(4)  # 12
IO.puts MyTest2.times_4(5)  # 20


## Using Bindings to Inject Values

defmodule My7 do
  defmacro mydef(name) do
    quote do
      def unquote(name)(), do: unquote(name)
    end
  end
end

defmodule Test7 do
  require My7
  # [ :fred, :bert ] |> Enum.each(&My7.mydef(&1))  # 'invalid syntax in def x1()'
end


defmodule My8 do
  defmacro mydef(name) do
    quote bind_quoted: [name: name] do
      def unquote(name)(), do: unquote(name)
    end
  end
end

defmodule Test8 do
  require My8
  [ :fred, :bert ] |> Enum.each(&My8.mydef(&1))
end

IO.puts Test8.fred
# fred


## Macros Are Hygienic

defmodule Scope do
  defmacro update_local(value) do
    local = "some value"
    result = quote do
      local = unquote(value)
      IO.puts "End of macro body, local = #{local}"
    end
    IO.puts "In macro definiton, local = #{local}"
    result
  end
end

defmodule ScopeTest do
  require Scope

  local = 123
  Scope.update_local("cat")
  IO.puts "On return, local = #{local}"
end
# In macro definiton, local = some value
# End of macro body, local = cat
# On return, local = 123


## Other Ways to Run Code Fragments

fragment = quote do: IO.puts("hi")
# {{:., [], [{:__aliases__, [alias: false], [:IO]}, :puts]}, [], ["hi"]}
Code.eval_quoted fragment
# hi
# {:ok, []}

fragment = quote do: IO.puts(var!(a))
# {{:., [], [{:__aliases__, [alias: false], [:IO]}, :puts]}, [],
#  [{:var!, [context: Elixir, import: Kernel], [{:a, [], Elixir}]}]}
Code.eval_quoted fragment, [a: "cat"]
# cat
# {:ok, [a: "cat"]}

fragment = Code.string_to_quoted("defmodule A do def b(c) do c+1 end end")
# {:ok,
#  {:defmodule, [line: 1],
#   [{:__aliases__, [counter: 0, line: 1], [:A]},
#    [do: {:def, [line: 1],
#      [{:b, [line: 1], [{:c, [line: 1], nil}]},
#       [do: {:+, [line: 1], [{:c, [line: 1], nil}, 1]}]]}]]}}
Macro.to_string(fragment)
# "{:ok, defmodule(A) do\n  def(b(c)) do\n    c + 1\n  end\nend}"

Code.eval_string("[a, a*b, c]", [a: 2, b: 3, c: 4])
# {[2, 6, 4], [a: 2, b: 3, c: 4]}


## Macros and Operators

defmodule Operations do
  defmacro a + b do
    quote do
      to_string(unquote(a)) <> to_string(unquote(b))
    end
  end
end

defmodule OperationsTest do
  IO.puts(123 + 456)      # 579
  import Kernel, except: [+: 2]
  import Operations
  IO.puts(123 + 456)      # 123456
end


## Digging

require Macro

Macro.binary_ops
# [:===, :!==, :==, :!=, :<=, :>=, :&&, :||, :<>, :++, :--, :\\, :::, :<-, :..,
#  :|>, :=~, :<, :>, :->, :+, :-, :*, :/, :=, :|, :., :and, :or, :when, :in, :~>>,
#  :<<~, :~>, :<~, :<~>, :<|>, :<<<, :>>>, :|||, :&&&, :^^^, :~~~]
Macro.unary_ops
# [:!, :@, :^, :not, :+, :-, :~~~, :&]
quote do: 1 + 2
# {:+, [context: Elixir, import: Kernel], [1, 2]}
Code.eval_quoted {:+, [], [1,2]}
# {3, []}


## Exercise:

defmodule Explaining do
  defmacro explain(clauses) do
    do_clause = Keyword.get(clauses, :do, nil)
    do_explain(do_clause, nil)
  end

  defp do_explain({op, _, [a, b]}, nil) when is_integer(a) and is_integer(b),
    do: do_translate(op, a, b)

  defp do_explain({op, _, [a, b]}, acc) when is_integer(a) and is_integer(b),
    do: acc <> ", then #{do_translate(op, a, b)}"

  defp do_explain({op, _, [a, b]}, acc) when is_integer(a) and is_tuple(b),
    do: do_explain(b, acc) <> do_translate(op, a)

  defp do_explain({op, _, [a, b]}, acc) when is_tuple(a) and is_integer(b),
    do: do_explain(a, acc) <> do_translate(op, b)

  defp do_explain({op, _, [a, b]}, acc) when is_tuple(a) and is_tuple(b) do
    acc = do_explain(a, acc)
    acc = do_explain(b, acc)
    acc <> do_translate(op)
  end

  defp do_translate(:+, a, b) when is_integer(a) and is_integer(b),
    do: "add #{a} to #{b}"
  defp do_translate(:-, a, b) when is_integer(a) and is_integer(b),
    do: "subtract #{b} from #{a}"
  defp do_translate(:*, a, b) when is_integer(a) and is_integer(b),
    do: "multiply #{a} by #{b}"
  defp do_translate(:/, a, b) when is_integer(a) and is_integer(b),
    do: "divide #{a} by #{b}"

  defp do_translate(:+, x) when is_integer(x), do: ", then add #{x}"
  defp do_translate(:-, x) when is_integer(x), do: ", then subtract by #{x}"
  defp do_translate(:*, x) when is_integer(x), do: ", then multiply by #{x}"
  defp do_translate(:/, x) when is_integer(x), do: ", then divide by #{x}"

  defp do_translate(:+), do: ", then add the results"
  defp do_translate(:-), do: ", then the second result from the first"
  defp do_translate(:*), do: ", then multiply the results"
  defp do_translate(:/), do: ", then divide the first result by the second"
end
