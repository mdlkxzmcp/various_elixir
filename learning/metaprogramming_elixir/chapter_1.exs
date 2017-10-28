# The Language of Macros

IO.inspect quote do: 5 + 2
# {:+, [context: Elixir, import: Kernel], [5, 2]}
IO.inspect quote do: 1 * 2 + 3
# {:+, [context: Elixir, import: Kernel],
#  [{:*, [context: Elixir, import: Kernel], [1, 2]}, 3]}

defmodule Math do
  # {:+, [context: Elixir, import: Kernel], [., .]}
  defmacro say({:+, _, [lhs, rhs]}) do
    quote do
      lhs = unquote(lhs)
      rhs = unquote(rhs)
      result = lhs + rhs
      IO.puts "#{lhs} plus #{rhs} is #{result}"
      result
    end
  end

  # {:*, [context: Elixir, import: Kernel], [., .]}
  defmacro say({:*, _, [lhs, rhs]}) do
    quote do
      lhs = unquote(lhs)
      rhs = unquote(rhs)
      result = lhs * rhs
      IO.puts "#{lhs} times #{rhs} is #{result}"
      result
    end
  end
end


## Re-Creating Elixir’s unless Macro

defmodule ControlFlow do
  defmacro unless(expression, do: block) do
    quote do
      if !unquote(expression), do: unquote(block)
    end
  end
end


## Injecting Code

defmodule Mod do
  defmacro definfo do
    IO.puts "In macro's context (#{__MODULE__})."

    quote do
      IO.puts "In caller's context (#{__MODULE__})."

      def friendly_info do
        IO.puts """
        My name is #{__MODULE__}
        My functions are #{inspect __info__(:functions)}
        """
      end
    end
  end
end

defmodule MyModule do
  require Mod
  Mod.definfo
end

defmodule Setter do
  defmacro useless_bind(value) do
    quote do
      name = unquote(value)
    end
  end

  defmacro working_bind(value) do
    quote do
      var!(name) = unquote(value)
    end
  end
end
