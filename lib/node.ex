defmodule DHT.Node do
  @doc """
  This is the server that communicates between other nodes. It should ensure that
  at least @replication_degree machines have the key, and atleast one of those
  machines should have a unique address. The @partioning_degree determines how
  many shards the input space is split into.

  The servers state is a map mapping every node to a shard index, 0..@partioning_degree.
  """
  @maxkey 4294967295
  @partioning_degree 4
  @replication_degree 3
  require Logger
  use GenServer

  def start_link do
    self_node = node()
    nodes = DHT.NodeList.node_list
    |> Stream.filter(fn node -> node != self_node end)
    |> Stream.filter(&Node.connect/1)
    |> Enum.map(fn node ->
      Logger.info("Connected to #{Atom.to_charlist(node)}")
      GenServer.cast({NodeService, node}, {:add_node, self_node})
    end)

    {shards, bad_nodes} = GenServer.multi_call(NodeService, :get_range, 100)
    shards = Enum.reduce(%{}, fn({node, shard}, acc) %Map.put(acc, node, shard))
    shard_count = shards
    |> Enum.reduce(&{}, &Map.update(&2, &1, 0, fn x -> x + 1))

    Logger.info "Started node server with name #{self_node}"
    GenServer.start_link(__MODULE__, %{
          :shards => 0},
      name: NodeService)
  end

  def handle_cast({:add_node, from_node}, state) do
    Logger.info "Connecting to #{from_node}"

    {:noreply, state}
  end

  def handle_call({:get_keys_from_range, range_start, range_end}, _from, state) do
    :void
  end

  def handle_call(:get_range, _from, state) do
    {:reply, 0, state}
  end
end
