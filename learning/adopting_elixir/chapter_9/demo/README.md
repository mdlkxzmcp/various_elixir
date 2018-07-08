# Demo

An Phoenix application demonstrating ways of instrumenting, load testing as well as profiling Ecto and Phoenix.

## Instrumentation
### Ecto:
In [`config/config.exs`](https://github.com/Mdlkxzmcp/various_elixir/tree/master/learning/adopting_elixir/chapter_9/demo/config/config.exs) an entry `config :demo, Demo.Repo, loggers: [Ecto.LogEntry, Demo.EctoInspector]` allows Ecto to display additional information to the terminal as described in [`lib/demo/ecto_inspector.ex`](https://github.com/Mdlkxzmcp/various_elixir/tree/master/learning/adopting_elixir/chapter_9/demo/lib/demo/ecto_inspector.ex). The inspector can be further customized to retrieve the measurements that matter and publish them to the data gathering services.

Another thing worth monitoring is the `Demo.Repo.Pool` process as it contains information on the resources Elixir is consuming to manage the database such as: memory usage, amount of reductions, and message queue length.

### Phoenix:
There exists a `instrument/3` macro function within the `Endpoint` which allows for, as name suggets, instrumentation of any events inside the web stack. Phoenix instruments on itself a few events such as:
  * `phoenix_controller_call` – measures how long the controller takes to process a request.
  * `phoenix_controller_render` – measures the time the controller takes to render the view.
  * `phoenix_channel_join` – records each time a user joins a channel.
  * `phoenix_channel_receive` – records each message received by a client on a channel.

[Custom instrumentations can be made too](https://hexdocs.pm/phoenix/Phoenix.Endpoint.html#module-using-instrumentation):
```Elixir
require DemoWeb.Endpoint
DemoWeb.Endpoint.instrument(
  :long_operation_in_controller,
  %{metadata: "data"},
  fn ->
    #code to be instrumented
  end
)
```

A specific Elixir module should be responsible for consuming those events by exporting functions with the same name as the events. Those functions will be called twice per event, at start and at the end. [An example of this with some more implementation details](https://github.com/Mdlkxzmcp/various_elixir/tree/master/learning/adopting_elixir/chapter_9/demo/lib/demo_web/phoenix_inspector.ex). The [`config/config.exs`](https://github.com/Mdlkxzmcp/various_elixir/tree/master/learning/adopting_elixir/chapter_9/demo/config/config.exs) needs an additional entry to tell Phoenix about this module – `config :demo, DemoWeb.Endpoint, instrumenters: [DemoWeb.PhoenixInspector]`.

Since the measurements are displayed in native units, it might be desirable to convert them: `System.convert_time_unit(64728, :native, :microseconds)` -> `64`.

## [Load Testing](https://www.theerlangelist.com/article/phoenix_latency)
### [Wrk](https://github.com/wg/wrk) – an HTTP benchmarking and load testing tool.
To use:
  1. `$ MIX_ENV=prod mix ecto.setup`
  2. `$ PORT=4040 MIX_ENV=prod mix phx.server`
  3. `$ wrk -t5 -c10 -d30s --latency http://127.0.0.1:4040/posts`

Where:
  * `-t5` means 5 threads
  * `-c10` means 10 connections
  * `-d30s` means run for 30 seconds
  * `--latency` adds additional information on latency distribution for various percentiles.

Various changes can be made to increase performance such as:
  * Setting the logger level to `:warn` in the `config/prod.exs`. Since metrics are in place, there's no reason to log all the information to disk on every request.
  * Increasing the number of keepalive requests. The limit may be increased by setting `protocol_options: [max_keepalive: 1_000_000]` under `:http` option in `lib/demo_web/endpoint.ex`. Cowboy, by default, allows at most 100 requests on the same connection before requiring the client to start a new one, which is a reasonable behavior for most browsers and clients, but can be changed for the test.
  * If there is an increased queue time in the Ecto metrics, changing the database `:pool_size` in `config/prod.secret.exs` may help solve this issue. However this is a pretty reasonable default otherwise, and changing it might actually cause more harm than good as both the database and Ecto perform a lot of caching per connection.

### [Tsung](https://github.com/processone/tsung)
A load testing tool written in Erlang that comes with:
  * A dashboard!
  * the load can be distributed on a cluster of client machines,
  * XML configuration system allowing for complex scenarios,
  * [and many more](http://tsung.erlang-projects.org/user_manual/features.html#features)

It can be used to test user interactions over different protocols such as [WebSockets](http://phoenixframework.org/blog/the-road-to-2-million-websocket-connections).


## Profiling
Elixir has three tools integrated into Mix from Erlang:
  * `cprof` – counts the invocations. Fast, with minimal impact on execution times. Should be used as a tool which gives a rough rundown of the modules and functions that were called in order to execute the profiled part of the system.
  * `eprof` – measures the execution time.
  * `fprof`– does both, meaning that it provides a ton of data, but has noticible impact on execution times. This can potentially skew the results. Processes that perform, for example, I/O operations are especially suseptable to this.

[An example of a profiler.](https://github.com/Mdlkxzmcp/various_elixir/tree/master/learning/adopting_elixir/chapter_9/demo/perf/post_index.exs) Can be invoked with: `$ PORT=4040, MIX_ENV=prod mix profile.fprof -r perf/post_index.exs -e "PostIndex.run" --callers --details --sort own`, where:
  * `-r` specifies path to the profilers to be loaded into memory.
  * `-e` evaluate given profiler function.
  * `--callers` adds detailed information about the callers and called functions.
  * `--details` includes profile data for each of the profiled processes.
  * `--sort` sorts the result by given key (acc by default).

This will return a table, (which starts with three entries. They are the result of the code being profiled in an anonymous function). The data is shown with:
  * `CNT` – count of times called
  * `ACC` – total time spent in a function and its children.
  * `OWN` – execution time of a function itself.

For more options and general info: `mix help profile.fprof`.
