This dir contains the output of running:

`$ mkdir ./log_1; run_erl ./number ./log_1 "elixir -e 'Enum.map(1..12, &IO.puts/1)'"` in `log_1`

and
```
$ run_erl -daemon ./iex_sample ./log_2 "iex"
$ to_erl ./iex_sample
> 1 + 2
3
System.stop()
```
in `log_2`


`System.stop()` can also be invoked by sending it via `to_erl`:

`$ echo "System.stop()" | to_erl ./iex_sample`
