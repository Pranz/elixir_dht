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
      {:error, :system_limit} ->
        Logger.warn "System limit for available connections reached!"
      anyval ->
        Logger.info "error on client connection: #{anyval}"
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
    case read_line(client) do
      :error ->
        :gen_tcp.close(client)
        :closed_client
      {:ok, data} ->
        command = DHT.Command.parse(data)
        case command do
          {:get, key} ->
            val = DHT.Bucket.get(key)
            write_line(client, "#{val}")
          {:put, key, value} ->
            DHT.Bucket.put(key, value)
            write_line(client, value)
          :error ->
            write_line(client, "Invalid command")
        end
        serve(client)
    end
  end

  defp read_line(client) do
    case :gen_tcp.recv(client, 0) do
      {:ok, data} -> {:ok, data}
      _ -> :error
    end
  end

  defp write_line(client, line) do
    :gen_tcp.send(client, "#{line}\r\n")
  end
end
