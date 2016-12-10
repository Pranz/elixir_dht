defmodule DHT.Node do
  use GenServer
  require Logger
  @maxkey 4294967295
  @partioning_degree 4
  @replication_degree 3
  @doc """
  This is the server that communicates between other nodes. It should ensure that
  at least @replication_degree machines have the key, and atleast one of those
  machines should have a unique address. The @partioning_degree determines how
  many shards the input space is split into.

  The servers state is a map mapping every node to a shard index, 0..@partioning_degree.
  """

  def start_link do
    self_node = node()
    nodes = connect_to_nodes

    {shards, bad_nodes} = GenServer.multi_call(NodeService, :get_shard)
    shards = Enum.reduce(shards, %{}, fn({node, shard}, acc) -> Map.put(acc, node, shard) end)
    {least_used_shard, _amount} = shard_count(shards)
    shards = Map.put(shards, self_node, least_used_shard)
    shard_count = DHT.Util.count_keys_with_same_val(shards)
    for shard_index <- 0..@partioning_degree-1 do
      shard_amount = Map.get(shard_count, shard_index, 0)
      if shard_amount < @replication_degree do
        Logger.warn("Not enough machines for shard #{shard_index}. Need #{@replication_degree}," <>
        "but only has #{shard_amount}")
      end
    end

    GenServer.abcast(NodeService, {:add_to_shard, self_node, least_used_shard})
    Logger.info "Started node server with name #{self_node}"
    Logger.info "Placed into shard #{least_used_shard}"
    GenServer.start_link(__MODULE__, %{
          :shards => shards},
      name: NodeService)
  end

  defp connect_to_nodes do
    self_node = node()
    DHT.NodeList.node_list
    |> Stream.filter(fn node -> node != self_node end)
    |> Stream.filter(&Node.connect/1)
    |> Enum.map(fn node ->
      Logger.info("Connected to #{Atom.to_charlist(node)}")
      GenServer.cast({NodeService, node}, {:add_node, self_node})
    end)
  end

  defp shard_count(shards) do
    shards = Enum.reduce(shards, %{}, fn({node, shard}, acc) -> Map.put(acc, node, shard) end)
    shard_count = shards
    |> DHT.Util.count_keys_with_same_val()
    shard_count = Enum.reduce(0..@partioning_degree-1, shard_count, fn(shard, acc) ->
      Map.put_new(acc, shard, 0)
    end)

    shard_count
    |> Enum.reduce({0, 999}, fn ({shard, amount}, {shard2, min_amount}) ->
      if amount < min_amount
        do {shard, amount}
        else {shard2, min_amount}
      end
    end)
  end

  def handle_cast({:add_node, from_node}, state) do
    Logger.info "Connecting to #{from_node}"

    {:noreply, state}
  end

  def handle_cast({:add_to_shard, node, shard}, state) do
    Logger.info "Adding #{node} to shard #{shard}"
    {:noreply, %{state | shards: Map.put(state.shards, node, shard)}}
  end

  def handle_call(:get_shard, _from, state) do
    {:reply, state.shards[node()], state}
  end

end
