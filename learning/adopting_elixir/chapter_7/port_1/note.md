Running `elixir all_caps.exs` starts an I/O device which will convert given message into all-caps.

The `program.exs` uses that fact to open up a port by spawning `elixir all_caps.exs` and configuring it to return binaries. Then it sends a message to that port using `send/2`, *just as if it was an Elixir process*. Finally it issues a message to close the port and waits for its termination. This implementation is asynchronous.

There is also a way to use Port API to achieve synchronous code as in `program_command.exs`.
