defmodule BC.Game.Supervisor do
  use Supervisor

  @name BC.Game.Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def start_game(number) do
    Supervisor.start_child(@name, [number])
  end

  def init(:ok) do
    children = [
      worker(BC.Game, [], restart: :temporary)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
