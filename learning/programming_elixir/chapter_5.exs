fizz_buzz = fn
  (0, 0, _) -> "FizzBuzz"
  (0, _, _) -> "Fizz"
  (_, 0, _) -> "Buzz"
  (_, _, a) -> a
end

call_fizz_buzz_with_rem = fn (n) -> fizz_buzz.(rem(n, 3), rem(n, 5), n) end

IO.puts call_fizz_buzz_with_rem.(10)
IO.puts call_fizz_buzz_with_rem.(11)
IO.puts call_fizz_buzz_with_rem.(12)
IO.puts call_fizz_buzz_with_rem.(13)
IO.puts call_fizz_buzz_with_rem.(14)
IO.puts call_fizz_buzz_with_rem.(15)
IO.puts call_fizz_buzz_with_rem.(16)


greeter = fn name -> (fn -> "Greetings #{name}!" end) end
mdlkxzmcp_greeter = greeter.("Max")

IO.puts mdlkxzmcp_greeter.()


add_n = fn n -> (fn other -> n + other end) end
add_two = add_n.(2)

IO.puts add_two.(8)


prefix = fn str -> (fn another_str -> str <> " " <> another_str end) end
sir = prefix.("Sir")

IO.puts sir.("Max.")
IO.puts prefix.("Elixir").("is the best functional language evaar!")


times_2 = &(&1 * 2)
apply = fn (fun, value) -> fun.(value) end

IO.puts apply.(times_2, 6)


defmodule Greeter do
  def for(name, greeting) do
    fn
      (^name) -> "#{greeting} #{name}!"
      (_) -> "そしてあなたは？"
    end
  end
end

mdlkxzmcp = Greeter.for("Max", "Welcome")

IO.puts mdlkxzmcp.("Max")
IO.puts mdlkxzmcp.("Bahtosh")

Enum.each [1, 2, 3, 4], &IO.inspect &1
