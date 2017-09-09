# Linking Modules: Behavio(u)rs and Use

## Tracing Method Calls

defmodule Tracer do
  defmacro def(definition, do: _content) do
    IO.inspect definition
    quote do: {}
  end
end

defmodule Test do
  import Kernel, except: [def: 2]
  import Tracer, only:   [def: 2]

  def puts_sum_three(a,b,c), do: IO.inspect(a+b+c)
  def add_list(list),        do: Enum.reduce(list, 0, &(&1+&2))
end

# Test.puts_sum_three(1,2,3)
# Test.add_list([5,6,7,8])

# {:puts_sum_three, [line: 16],
#  [{:a, [line: 16], nil}, {:b, [line: 16], nil}, {:c, [line: 16], nil}]}
# {:add_list, [line: 17], [{:list, [line: 17], nil}]}
# ** (UndefinedFunctionError) function Test.puts_sum_three/3 is undefined or private


defmodule Tracer2 do
  defmacro def(definition, do: content) do
    quote do
      Kernel.def(unquote(definition)) do
        unquote(content)
      end
    end
  end
end

defmodule Test2 do
  import Kernel, except: [def: 2]
  import Tracer2, only:  [def: 2]

  def puts_sum_three(a,b,c), do: IO.inspect(a+b+c)
  def add_list(list),        do: Enum.reduce(list, 0, &(&1+&2))
end

Test2.puts_sum_three(1,2,3)
Test2.add_list([5,6,7,8])

# {:puts_sum_three, [line: 16],
#  [{:a, [line: 16], nil}, {:b, [line: 16], nil}, {:c, [line: 16], nil}]}
# {:add_list, [line: 17], [{:list, [line: 17], nil}]}
# 6


defmodule Tracer3 do
  def dump_args(args) do
    args |> Enum.map(&inspect/1) |> Enum.join(", ")
  end

  def dump_def(name, args) do
    "#{name}(#{dump_args(args)})"
  end

  defmacro def(definition={name, _, args}, do: content) do
    quote do
      Kernel.def(unquote(definition)) do
        IO.puts "  ==> call: #{Tracer3.dump_def(unquote(name), unquote(args))}"
        result = unquote(content)
        IO.puts "<== result: #{result}"
        result
      end
    end
  end
end

defmodule Test3 do
  import Kernel, except: [def: 2]
  import Tracer3, only:  [def: 2]

  def puts_sum_three(a,b,c), do: IO.inspect(a+b+c)
  def add_list(list),        do: Enum.reduce(list, 0, &(&1+&2))
end

Test3.puts_sum_three(1,2,3)
Test3.add_list([5,6,7,8])

#   ==> call: puts_sum_three(1, 2, 3)
# 6
# <== result: 6
#   ==> call: add_list([5, 6, 7, 8])
# <== result: 26

defmodule Tracer4 do
  def dump_args(args) do
    args |> Enum.map(&inspect/1) |> Enum.join(", ")
  end

  def dump_def(name, args) do
    "#{name}(#{dump_args(args)})"
  end

  defmacro def(definition={name, _, args}, do: content) do
    quote do
      Kernel.def(unquote(definition)) do
        IO.puts "  ==> call: #{Tracer4.dump_def(unquote(name), unquote(args))}"
        result = unquote(content)
        IO.puts "<== result: #{result}"
        result
      end
    end
  end

  defmacro __using__(_opts) do
    quote do
      import Kernel,            except: [def: 2]
      import unquote(__MODULE__), only: [def: 2]
    end
  end
end

defmodule Test4 do
  use Tracer4

  def puts_sum_three(a,b,c), do: IO.inspect(a+b+c)
  def add_list(list),        do: Enum.reduce(list, 0, &(&1+&2))
end

Test4.puts_sum_three(1,2,3)
Test4.add_list([5,6,7,8])

#   ==> call: puts_sum_three(1, 2, 3)
# 6
# <== result: 6
#   ==> call: add_list([5, 6, 7, 8])
# <== result: 26


## Exercises:

defmodule ANSITracer do

  def dump_args(args) do
    args |> Enum.map(&inspect/1) |> Enum.join(", ")
  end

  def dump_def(name, args) do
    IO.ANSI.format([:green, "#{name}", "(#{dump_args(args)})"], true)
  end

  defmacro def(definition={name, _, args}, do: content) do
    quote do
      Kernel.def(unquote(definition)) do
        IO.puts "  ==> call: #{ANSITracer.dump_def(unquote(name), unquote(args))}"
        result = unquote(content)
        IO.puts IO.ANSI.format(["<== result: ", :bright, "#{result}"], true)
        result
      end
    end
  end

  defmacro __using__(_opts) do
    quote do
      import Kernel,            except: [def: 2]
      import unquote(__MODULE__), only: [def: 2]
    end
  end
end

defmodule TestANSI do
  use ANSITracer
  
  def puts_sum_three(a,b,c), do: IO.inspect(a+b+c)
  def add_list(list),        do: Enum.reduce(list, 0, &(&1+&2))
end

TestANSI.puts_sum_three(1,2,3)
TestANSI.add_list([5,6,7,8])
