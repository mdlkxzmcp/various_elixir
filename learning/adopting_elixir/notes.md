# Notes

## Chapter 3 – Ensuring Code Consistency
See [`belief_structure`](https://github.com/Mdlkxzmcp/various_elixir/tree/master/learning/adopting_elixir/chapter_3/belief_structure) dir for `mix.exs` example of the following tools:
* `mix credo --strict` / `mix credo _path/_file.ex:_line` -> [linter](https://github.com/rrrene/credo)
* `mix dialyzer` -> [type check](https://github.com/jeremyjh/dialyxir)
* `mix docs` -> [generate documentation](https://github.com/elixir-lang/ex_doc)
* `mix inch` -> [documentation coverage](https://github.com/rrrene/inch_ex)
* `mix coveralls` / `mix coveralls.detail` / `mix coveralls.html` -> [test coverage](https://github.com/parroty/excoveralls)

Those can be added to any project for a greater code consistency, requiring only slight changes in the `mix.exs` file.

Other interesting libraries:
* [Bypass](https://github.com/PSPDFKit-labs/bypass) -> running a web API on the same VM as the tests.
* [Mox](https://github.com/plataformatec/mox) -> if *really* needed, an option for mocking.
* [Bureaucrat](https://github.com/api-hogs/bureaucrat) -> Phoenix API documentation! (requires a bit of configuration but well worth it~)

---

## Chapter 4 – Legacy Systems and Dependencies
* [terraform](https://github.com/poteto/terraform) -> great library for incrementally replacing a legacy web application.
* `mix hex.outdated` / `mix hex.outdated _package` / `mix hex.audit` -> managing third-party dependencies.

### [Umbrella Projects](https://elixir-lang.org/getting-started/mix-otp/dependencies-and-umbrella-projects.html#umbrella-projects)
The Umbrella project structure allows for easy separation of modules into sub-apps that share (by default) only four lines of code:
```Elixir
build_path: "../../_build",
config_path: "../../config/config.exs",
deps_path: "../../deps",
lockfile: "../../mix.lock",
```
The coupling means that any dependency shared by the apps have to use the same version with the exact same configurations. It sits between a Monolith and Services (being way closer to SOA).

[*An example of an Umbrella project.*](https://github.com/Mdlkxzmcp/various_elixir/tree/master/learning/adopting_elixir/chapter_4/my_umbrella)

---

## Chapter 6 – Distributed Elixir
### Persistence Strategies
It is important to determine the type of data used by the application. If it cannot be lost, a database is the way to go. On the other hand, if the data is disposable, it might be possible to store it in a GenServer. The best case scenario is unchanging data. This allows for storing the data as serialized data structures using the [`:erlang.term_to_binary/1`](http://erlang.org/doc/man/erlang.html#term_to_binary-1) and [`:erlang.binary_to_term/1`](http://erlang.org/doc/man/erlang.html#binary_to_term-1).


### Finding Processes
There are two kinds of registries, which allow for uniquely naming processes - local and distributed.

#### Local Registries
The default way of registering names is with the atom registry. It binds an atom to a process (defining module in Elixir for simplification of introspection and debugging) which then cannot be seen by other nodes, but can still be accessed by them indirectly. Atom registry **should not be used** when registering dynamically. The [`Registry`](https://hexdocs.pm/elixir/Registry.html) module allows for dynamic registration of non-atom names. It also allows for local grouping, more on that in *Process Groups*.

#### Distributed Registries
A distributed alternative is [`:global`](http://erlang.org/doc/man/global.html), which is still atom based, but makes the processes visible to all nodes at the same time. Each node keeps a copy of registered processes. As the number of nodes grows, registration becomes more expensive due to coordination. This approach best works for eternal processes. [All the limitations are documented](https://ieeexplore.ieee.org/document/7820204). And if needed, a possible alternative is [Syn](https://github.com/ostinelli/syn), a global Process Registry and Process Group manager for Erlang.

#### Process Groups
Like registries, process groups may be local or distributed. They allow for grouping processes under a given topic or property.

##### [The `Registry` Module](https://hexdocs.pm/elixir/Registry.html)
[`Registry`](https://hexdocs.pm/elixir/Registry.html) has two modes of operation – unique keys for process registry, and duplicate, which stores multiple entries under each key:

```Elixir
> Registry.start_link(keys: :duplicate, name: ProcessGroup)
{:ok, $PID}
> {:ok, _} = Registry.register(ProcessGroup, "workers", :high)
> {:ok, _} = Registry.register(ProcessGroup, "workers", :low)
> Registry.lookup(ProcessGroup, "workers")
[{$PID_1, :high}, {$PID_1, :low}]
```
[`Registry.register/3`](https://hexdocs.pm/elixir/Registry.html#register/3) registers the current process under `(registry, key, value)`, where the `key` is the group name, and `value` is some property of the registration. It is possible to send a message to all processes in a cluster that belong to a given group by using a combination of `GenServers`, `Node.list/0` and `send/2` in order to brodcast the message through the `handle_info/2` callback of each `GenServer`. [This is effectively a distributed pubsub.](http://erlang.org/doc/man/registry.html)

##### [The `:pg2` Module](http://erlang.org/doc/man/pg2.html)
Another way of implementing a pubsub with distribution in mind is through [the `:pg2` module](http://erlang.org/doc/man/pg2.html). It is like [`:global`](http://erlang.org/doc/man/global.html), in the sense that joining a group happens atomically across the whole cluster, and each node keeps a copy of the groups. That gives the advantage over [`Registry`](https://hexdocs.pm/elixir/Registry.html) when doing other things than pubsubs. It sadly bears the same downside, too, meaning that joining becomes increasingly more expensive as the cluster grows. This means that it should **not** be used for dynamic registrations.

##### Alternatives
The community has created various other solutions – [`Phoenix.PubSub`](https://hexdocs.pm/phoenix_pubsub/api-reference.html), [`Phoenix.Presence`](https://hexdocs.pm/phoenix/Phoenix.Presence.html), which uses a distributed process group implementation called [`Phoenix.Tracker`](https://hexdocs.pm/phoenix_pubsub/Phoenix.Tracker.html), and many others. [`Phoenix.Tracker`](https://hexdocs.pm/phoenix_pubsub/Phoenix.Tracker.html) exchanges local group informations in a node with others in the cluster periodically. Such a system is *eventually consistent*.


### Cache and [ETS](http://erlang.org/doc/man/ets.html)
The Erlang Term Storage provides a high-level mechanism for storing data in-memory. If the cache can be made cheaply, it's better for each node to have its own local ETS as it is highly efficient. A good abstration of ETS is the [`con_cache`](https://github.com/sasa1977/con_cache). In the case a local cache is not enough, a process group implementation with a list of processes across the cluster that hold certain caches is an option. If that is not good enough, it is possible to build the cache in the background and update the *global* storage, such as a database.


### Message Delivery Guarantees
There are three main event types which include message delivery:
* #### at-most-once
When nothing bad happens if a message doesn't arrive. Requires no additional work.
* #### at-least-once
There is a need for a persistence mechanism as loosing a message is problematic. [RabbitMQ](https://www.rabbitmq.com) ([on Github](https://github.com/rabbitmq/rabbitmq-server)) is a standard third-party solution.
* #### exacly-once
In some cases, a message has to be recieved, but only once. In such situations, passing a unique ID that identifies given message is a way to guarantee that it is idempotent.

---

## Chapter 7 – [Integrating with External Code](https://erlang.org/doc/tutorial/overview.html)
There are three main strategies for such integration, each with a different level of coupling:


### [NIFs](http://erlang.org/doc/man/erl_nif.html)
Native implemented functions allow loading code into the same memory address space as the Erlang VM. ([An implementation with a Makefile](https://github.com/Mdlkxzmcp/various_elixir/tree/master/learning/adopting_elixir/chapter_7/elixir_nif)). They are usafe due to the fact, that:
  - a crash in a NIF crashes the whole node, not just one process;
  - they can lead to internal VM inconsistencies, so unexpected behavior and crashes are to be expected;
  - NIFs may also interfere with scheduling, as their work doesn't stop until finished. It may also cause extreme memory usage. Fun stuff :=]

#### Preemption and Dirty Schedulers
By default, for each core, the BEAM VM starts a thread that runs a scheduler. The scheduler is responsible for the *soft* real-time guarantees of the system. Each process is given by the scheduler a discrete number of reductions. When it runs its allocation, the VM preempts it to allow the next one to run (aka. *preemptive multitasking*). There are specific points of execution where a process **can** actually be suspended such as at a receive or a function call.

Some processes might have higher priority causing the BEAM to interrupt anothers work in order to *try* (as in still give reductions for completion, sooner rather than later) to do the work of the more "important" one. This is called *preemptive scheduling*. Another type is *cooperative scheduling*, where the control is given to the task, and it will do its work until finished or it *yields*. BEAM actually uses a combination of those, *preemptive* for Elixir/Erlang, and (hopefully) *cooperative* for NIFs.

There is also a feature called *dirty schedulers* – There are two categories of dirty schedulers – I/O bound and CPU bound. The VM starts 10 threads as I/O-bounds and one CPU-bound for each core. The shell displays informations on them – "`[ds:8:8:10]`", showing 8 CPU schedulers, 8 active, and 10 I/O ones respectively.
#### [Long-running NIF Solutions](https://youtu.be/FYQcn9zcZVA?t=8m58s)
* Dirty NIF – a NIF that cannot be split and cannot execute in a milisecond or less. A "dirty NIF" does not mean "faster NIF" though, as it just doesn't block the normal schedulers.
* Yielding NIF ([timeslice](http://erlang.org/doc/man/erl_nif.html#enif_consume_timeslice)) – Involves splitting the NIF into a series of chunks. The oficially preffered method. May still cause problems at longer periods.
* *Yielding Dirty NIF* – A combination of yielding and dirty, where a yielding NIF is run on one of the dirty schedulers. Very good performence at longer periods.
* Threaded NIF – done by dispatching the work to another thread.

[A great resource for more info on NIFs.](https://github.com/potatosalad/elixirconf2017)


### [Ports](https://hexdocs.pm/elixir/Port.html)

A more stable and reliable alternative to NIFs. Each port starts the called software as a separate process in the OS. An example of this would be:
```Elixir
System.cmd("elixir", ["-e", "IO.puts(21 * 2)"])
{"42\n", 0}
```
If it terminates, the calling code gets a tuple "`{result, status_code}`". Similar to processes, ports are asynchronous. `System.cmd` hides this communication behind a synchronous command that blocks the current process until the executable exits.

[An example of both – using Port API, and `send/2` to achieve similar results](https://github.com/Mdlkxzmcp/various_elixir/tree/master/learning/adopting_elixir/chapter_7/port_1) (see [note.md](https://github.com/Mdlkxzmcp/various_elixir/tree/master/learning/adopting_elixir/chapter_7/port_1/note_md) for more info).

[There are various options that can be passed to `Port.open/2.`](http://erlang.org/doc/man/erlang.html#open_port-2) Some examples:
* `:exit_status` -> sends a status message on termination;
* `:cd` -> starts the port with the given current working directory;
* `:args` -> passes a list of arguments to the port;
* `:env` -> executes the port program with additional environment variables;
* `:use_stdio` -> allows the standard i/o (file descriptors 0 and 1);
* `:nouse_stdio` -> uses file descriptors 3 and 4 for communication instead of the standard io. For when the software writes messages that shouldn't be displayed on the stdio;
* [`packet: N`](https://github.com/Mdlkxzmcp/various_elixir/tree/master/learning/adopting_elixir/chapter_7/port_2) -> instructs the port to automatically include a number of bytes: 1, 2, or 4, at the beginning of every message with the message length. This way it becomes aparent how long each message is, and the `Port` module takes care of only delivering the response when it is complete.

#### Termination and Zombie Processes
In the case of VM crash or abrupt port termination, a long-running program started by the port will have its io channels closed but **it won't be automatically terminated**. [There are solutions for those *zombie processes*, such as bash script wraps.](https://hexdocs.pm/elixir/Port.html#module-zombie-processes)

#### Pools
If concurrent usage of ports is expected, pooling is a way to limit the amount of ports started. One library that helps with this is [poolboy](https://github.com/devinus/poolboy). It starts a certain amount of processes configured at startup, each with its own port.


### The Erlang Distribution Protocol
As long as a language or a platform implements the Erlang distribution protocol, it is possible to use that language to communicate with Erlang nodes.
Such implementation requires serialization and deserialization of Erlang data structures into binaries, plus the capability to communicate with [Erlang's Port Mapper Daemon (EPMD)](https://erlang.org/doc/man/epmd.html). OTP ships with implementations for [C (ErlInterface)](https://erlang.org/doc/apps/erl_interface/ei_users_guide.html) and [Java (JInterface)](https://erlang.org/doc/apps/jinterface/jinterface_users_guide.html).


### Alternatives
Built on top of Ports:
* [Porcelain](https://github.com/alco/porcelain) -> sane API for using ports to communicate with external OS processes from Elixir.
* [Erlexec](https://github.com/saleyn/erlexec) -> Execute and control OS processes from Erlang/OTP
* [ErlPort](https://github.com/jdoig/erlport) -> integration with Ruby and Python (fork, main repo appears to be dead :<)
NIFs:
* [Rustler](https://github.com/hansihe/rustler) -> Safe Rust bridge for creating NIFs.

---
