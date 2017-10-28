# Extending Elixir with Metaprogramming

## Custom Language Constructs

### Re-Creating the if Macro

defmodule ControlFlow do

  defmacro my_if(expr, do: if_block), do: if(expr, do: if_block, else: nil)
  defmacro my_if(expr, do: if_block, else: else_block) do
    quote do
      case unquote(expr) do
        result when result in [false, nil] -> unquote(else_block)
        _ -> unquote(if_block)
      end
    end
  end
end


### Adding a while Loop to Elixir

defmodule Loop do

  defmacro while(expression, do: block) do
    quote do
      try do
        for _ <- Stream.cycle([:ok]) do
          if unquote(expression) do
            unquote(block)
          else
            Loop.break
          end
        end
      catch
        :break -> :ok
      end
    end
  end

  def break, do: throw :break
end


## Smarter Testing with Macros

### Supercharged Assertions and Using Module Attributes for Code Generation

defmodule Assertion do

  defmacro __using__(_options) do
    quote do
      import unquote(__MODULE__)
      Module.register_attribute __MODULE__, :tests, accumulate: true
      def run do
        IO.puts "Running the tests (#{inspect @tests})"
      end
    end
  end

  defmacro test(description, do: test_block) do
    test_func = String.to_atom(description)
    quote do
      @tests {unquote(test_func), unquote(description)}
      def unquote(test_func)(), do: unquote(test_block)
    end
  end

  # {:., [context: ., import: .], [., .]}
  defmacro assert({operator, _, [lhs, rhs]}) do
    quote bind_quoted: [operator: operator, lhs: lhs, rhs: rhs] do
      Assertion.Test.assert(operator, lhs, rhs)
    end
  end


end

defmodule Assertion.Test do
  def assert(:==, lhs, rhs) when lhs == rhs do
    IO.write "."
  end
  def assert(:==, lhs, rhs) do
    IO.puts """
    FAILURE:
      Expected:       #{lhs}
      to be equal to: #{rhs}
    """
  end

  def assert(:>, lhs, rhs) when lhs > rhs do
    IO.write "."
  end
  def assert(:>, lhs, rhs) do
    IO.puts """
    FAILURE:
      Expected:           #{lhs}
      to be greater than: #{rhs}
    """
  end
end

defmodule MathTest do
  use Assertion

  assert 5 == 5
  assert 10 > 0
  assert 1 > 2
  assert 10 * 10 == 100
end
