defmodule BCServer.CommandTest do
  use ExUnit.Case, async: true

  test "parses commands from command line" do
    assert BCServer.Command.parse("CREATE game 3\r\n")  == {:ok, {:create, "game", "3"}}
    assert BCServer.Command.parse("GUESS game 123\r\n") == {:ok, {:guess, "game", "123"}}
    assert BCServer.Command.parse("EXIT\r\n")           == {:ok, {:exit}}
  end

  test "runs the CREATE command" do
    assert {:ok, "OK\r\n"} == BCServer.Command.run({:create, "game", "3"})
  end

  test "runs the GUESS command" do
    BCServer.Command.run({:create, "game", "3"})
    {:ok, game} = BC.Registry.lookup(BC.Registry, "game")
    Agent.update(game, &Map.put(&1, :secret, "123"))

    assert {:ok, "132: 1 bull and 2 cows\r\n"} == BCServer.Command.run({:guess, "game", "132"})
    assert {:ok, "YOU WON\r\n"} == BCServer.Command.run({:guess, "game", "123"})
  end

  test "run the EXIT command" do
    assert {:ok, :exit} == BCServer.Command.run({:exit})
  end

  test "stops game for player who won" do
    BCServer.Command.run({:create, "game", "3"})
    {:ok, game} = BC.Registry.lookup(BC.Registry, "game")
    Agent.update(game, &Map.put(&1, :secret, "123"))
    BCServer.Command.run({:guess, "game", "123"})

    assert BC.Registry.lookup(BC.Registry, "game") == :error
  end
end
