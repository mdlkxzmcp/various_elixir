# Benchmark
A benchmarking example with two seemingly similar implementations in [`perf/file_bench.exs`](https://github.com/Mdlkxzmcp/various_elixir/tree/master/learning/adopting_elixir/chapter_9/benchmark/perf/file_bench.exs). Uses [Benchee](https://github.com/PragTob/benchee).

A `words.txt` [file](https://github.com/dwyl/english-words/blob/master/words.txt) needs to be included in the project directory for the benchmark to run.

Execute with `$ mix run -r perf/file_bench.exs -e "FileBench.exs"`
