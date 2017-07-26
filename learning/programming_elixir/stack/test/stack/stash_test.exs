defmodule Stack.StashTest do
  use ExUnit.Case

  @test_stack [1, 2, 3]

  test "get_stack retrieves the stack from the stash" do
    {:ok, pid} = Stack.Stash.start_link(@test_stack)

    assert Stack.Stash.get_stack(pid) == @test_stack
  end

  test "save_stack stores given stack in the stash" do
    {:ok, pid} = Stack.Stash.start_link([])

    Stack.Stash.save_stack(pid, @test_stack)

    assert Stack.Stash.get_stack(pid) == @test_stack
  end

end
