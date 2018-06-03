Compile with: `javac -classpath "path_to_erlang/lib/jinterface-version/priv/OtpErlang.jar" EchoServer.java`

To run the server: `java -classpath ".:path_to_erlang/lib/jinterface-version/priv/OtpErlang.jar" EchoServer`

To verify it is running: `epmd -names`

Connect to this node by:
`iex --sname elixir`
```Elixir
> Node.connect(:"java@pc")
true
> send({:echo, :"java@pc"}, {self(), "hello"})
{PID<0..>, "hello"}
> flush()
{PID<8579..>, "hello"}
:ok
```
