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
        parsed_input = data
        |> String.replace_trailing("\r\n", "")
        |> Integer.parse()
        case parsed_input do
          {key, _binary_rem} ->
            val = DHT.Bucket.get(key)
            :gen_tcp.send(client, "Here's the val: #{val}\r\n")
          :error -> :void
        end
        serve(client)
    end
  end

  defp read_line(client) do
    case :gen_tcp.recv(client, 0) do
      {:ok, data} -> {:ok, data}
      _ ->
        :error
    end
  end
end
