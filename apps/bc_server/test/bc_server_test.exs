defmodule BCServerTest do
  use ExUnit.Case

  setup do
    Application.stop(:bc)
    :ok = Application.start(:bc)
  end

  setup do
    opts = [:binary, packet: :line, active: false]
    {:ok, socket} = :gen_tcp.connect('localhost', 4040, opts)
    {:ok, socket: socket}
  end

  test "server interaction", %{socket: socket} do
    assert send_and_recv(socket, "UNKNOWN game\r\n") ==
           "UNKNOWN COMMAND\r\n"

    assert send_and_recv(socket, "CREATE game 3\r\n") ==
           "OK\r\n"
  end

  defp send_and_recv(socket, command) do
    :ok = :gen_tcp.send(socket, command)
    {:ok, data} = :gen_tcp.recv(socket, 0, 1000)
    data
  end
end
