defmodule BC do
  use Application

  def start(_type, _args) do
    BC.Supervisor.start_link
  end
end
