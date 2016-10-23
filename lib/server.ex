defmodule DHT.Server do
  require Logger

  def listen(ports) do
    [{port, {:ok, socket}}] = ports
    |> Stream.map(&try_listen/1)
    |> Stream.filter(&match?({_, {:ok, _}}, &1))
    |> Enum.take(1)

    # {:ok, socket} = :gen_tcp.listen(port,
    #  [:binary, packet: :line, active: false, reuseaddr: true])
    Logger.info "listening on #{port}"
    accept(socket)
  end

  @doc """
  Tries to listen to port. Returns port and the response from
  :gen_tcp.listen
  """
  defp try_listen(port) do
    {port,:gen_tcp.listen(port,
      [:binary, packet: :line, active: false, reuseaddr: true])}
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
        result = DHT.Bucket.exec_tuple_command(command)
        write_result(client, result)
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

  defp write_result(client, result) do
    case result do
      {:error, err} -> write_line(client, "error: #{err}")
      res -> write_line(client, "#{res}")
    end
  end
end
