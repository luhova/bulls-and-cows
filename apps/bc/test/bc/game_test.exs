defmodule BC.GameTest do
  use ExUnit.Case, async: true

  setup do
     {:ok, game} = BC.Game.start_link("3")
     {:ok, game: game}
   end

  test "stores values by key", %{game: game} do
    secret = Agent.get(game, &Map.get(&1, :secret))
    assert String.length(secret) == 3
  end

  test "returns the right number of bulls and cows", %{game: game} do
    Agent.update(game, &Map.put(&1, :secret, "123"))
    
    assert BC.Game.guess(game, "321") == {:ok, {1, 2}}
    assert BC.Game.guess(game, "312") == {:ok, {0, 3}}
    assert BC.Game.guess(game, "567") == {:ok, {0, 0}}
    assert BC.Game.guess(game, "123") == {:ok, :win}
  end
end
