defmodule BC.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      worker(BC.Registry, [BC.Registry]),
      supervisor(BC.Game.Supervisor, [])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
