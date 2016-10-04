defmodule DHT.Node do
  require Logger
  
  def listen(port) do
    {:ok, socket} = :gen_tcp.listen(port,
      [:binary, packet: :line, active: false, reuseaddr: true])
    Logger.info "listening on 4040"
    accept(socket)
  end
  
  defp accept(socket) do
    case :gen_tcp.accept(socket) do
      {:ok, client} ->
        init_client(client)
      {:error, :timeout} ->
        Logger.info "client timed out"
      {:error, :system_limit} ->
        Logger.warn "System limit for available connections reached!"
      anyval -> Logger.info "error on client connection: #{anyval}"
    end

    accept(socket)
  end

  defp init_client(client) do
    {:ok, pid} = Task.Supervisor.start_child(:client_connection, fn ->
      serve(client)
    end)
    :ok = :gen_tcp.controlling_process(client, pid)
  end

  defp serve(client) do
    val = read_line(client) |> B.get(:bucket)
    :gen_tcp.send(client, "Here's the val: #{val}")
  end

  defp read_line(client) do
    {:ok, data} = :gen_tcp.recv(client, 0)
    data
  end
end
