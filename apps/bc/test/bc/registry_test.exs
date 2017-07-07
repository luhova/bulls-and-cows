defmodule BC.RegistryTest do
  use ExUnit.Case, async: true

  setup context do
    {:ok, registry} = BC.Registry.start_link(context.test)
    {:ok, registry: registry}
  end

  test "spawns games", %{registry: registry} do
    assert BC.Registry.lookup(registry, "game1") == :error

    BC.Registry.create(registry, "game1", "3")
    assert {:ok, game} = BC.Registry.lookup(registry, "game1")
    
    secret = Agent.get(game, &Map.get(&1, :secret))
    assert String.length(secret) == 3
  end

  test "removes game on exit", %{registry: registry} do
    BC.Registry.create(registry, "game1", "3")
    {:ok, game} = BC.Registry.lookup(registry, "game1")
    Agent.stop(game)
    assert BC.Registry.lookup(registry, "game1") == :error
  end

  test "removes game on crash", %{registry: registry} do
    BC.Registry.create(registry, "game1", "3")
    {:ok, game} = BC.Registry.lookup(registry, "game1")

    ref = Process.monitor(game)
    Process.exit(game, :shutdown)

    assert_receive {:DOWN, ^ref, _, _, _}

    assert BC.Registry.lookup(registry, "game1") == :error
  end
end
