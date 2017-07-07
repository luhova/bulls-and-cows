defmodule BCServer.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Task.Supervisor, [[name: BCServer.TaskSupervisor]]),
      worker(Task, [BCServer, :accept, [4040]])
    ]

    opts = [strategy: :one_for_one, name: BCServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
