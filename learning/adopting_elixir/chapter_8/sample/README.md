# Sample

An example of using [`Distillery`](https://github.com/bitwalker/distillery) for deployment. This includes some other dependencies just to mix things up a bit.
A initial [release structure](https://github.com/Mdlkxzmcp/various_elixir/tree/master/learning/adopting_elixir/chapter_8/sample/rel) can be invoked with `$ mix release.init`, which can be further tweaked and later actually built with `$ mix release` (for production `MIX_ENV=prod mix release`).

The [`config.exs` file](https://github.com/Mdlkxzmcp/various_elixir/tree/master/learning/adopting_elixir/chapter_8/sample/rel/config.exs) in the [`rel` directory](https://github.com/Mdlkxzmcp/various_elixir/tree/master/learning/adopting_elixir/chapter_8/sample/rel) (made by Distillery) has a section `release :sample` which, as one of its functions, declares the `:runtime_tools` that consist of both applications required to run the main application as well as various tools for debugging and observing production systems. It can be further extended with arguments to be passed to the VM as [`vm.args` file](https://github.com/Mdlkxzmcp/various_elixir/tree/master/learning/adopting_elixir/chapter_8/sample/rel/vm.args) with `set(vm_args: "rel/vm.args")`.

---

The whole release can be later found in `_build/prod/rel/sample/` (which isn't included in the repo) and contains:
* `./bin/` which holds various scripts for running the release, including `./sample` that can be invoked as:
  - daemon process – `./sample start`
  - interactive process – `./sample console`
  - foreground process – `./sample foreground`
  - graceful shutdown (`System.stop()`) – `./sample stop`
* `./erts/` which contains the Erlang Runtime System
* `./lib/` containing all applications that are a part of the release (versioned)
* `./releases/` that holds metadata about the releases and everything required to start the system, including things in `./0.1.0/`:
  - `sample.tar.gz` is the artifact
  - `sample.rel` describes the release with its name, version, and all applications that are part of the release
  - `sample.script` gets built from `sample.rel` which contains every instruction the runtime will perform when it boots (including module preloading)
  - `sample.boot` is a binary written from `sample.script`
  - `vm.args` includes the arguments given to the VM. It can be properly modified if it is included in the [`rel` directory](https://github.com/Mdlkxzmcp/various_elixir/tree/master/learning/adopting_elixir/chapter_8/sample/rel/vm.args).
