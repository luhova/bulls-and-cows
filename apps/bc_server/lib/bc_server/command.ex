defmodule BCServer.Command do
  def parse(line) do
    case String.split(line) do
      ["CREATE", game, number] -> {:ok, {:create, game, number}}
      ["GUESS", game, number] -> {:ok, {:guess, game, number}}
      ["EXIT"] -> {:ok, {:exit}}
      _ -> {:error, :unknown_command}
    end
  end

  def run({:create, game, number}) do
    BC.Registry.create(BC.Registry, game, number)
    {:ok, "OK\r\n"}
  end

  def run({:guess, game, number}) do
    lookup game, fn pid ->
      case BC.Game.guess(pid, number) do
        {:ok, :win} ->
          Agent.stop(pid)
          {:ok, "YOU WON\r\n"}
        {:ok, {b,c}} -> {:ok, "#{number}: #{b} #{bulls(b)} and #{c} #{cows(c)}\r\n"}
      end
    end
  end

  def run({:exit}) do
    {:ok, :exit}
  end

  defp bulls(number) do
    if number == 1 do
      "bull"
    else
      "bulls"
    end
  end

  defp cows(number) do
    if number == 1 do
      "cow"
    else
      "cows"
    end
  end

  defp lookup(game, callback) do
    case BC.Registry.lookup(BC.Registry, game) do
      {:ok, pid} -> callback.(pid)
      :error -> {:ok, "A game with name #{game} is not created\r\n"}
    end
  end
end
