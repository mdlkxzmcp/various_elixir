defmodule SomeModule do
  def get_those_packages_out do
    packages = ["Book", "Bat", "Broom", "Bananas"]
    {:ok, pid} = PackageReceiver.start_link
    Enum.each(packages, fn(package) ->
      IO.puts "Delivering package: #{package}"
      
      PackageReceiver.leave_at_the_door(pid, package)
    end)
    
    IO.puts "All done with deliveries"
    IO.puts "________________________"
  end
end


defmodule PackageReceiver do
  use GenServer
  
  def start_link do
    GenServer.start_link(__MODULE__, [])
  end
  
  def leave_at_the_door(receiver_pid, package_name) do
    GenServer.cast(receiver_pid, {:async_package, package_name})
  end
  
  def handle_cast({:async_package, package_name}, state) do
    :timer.sleep(1000)
    IO.puts "I recieved package: #{package_name}"
    {:noreply, state}
  end
end
