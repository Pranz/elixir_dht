defmodule DHT.Node do
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
      node
    end)

    Logger.info "Started node server with name #{self_node}"
    GenServer.start_link(__MODULE__, %{nodes: nodes}, name: NodeService)
  end

  def handle_cast({:add_node, from_node}, state) do
    Logger.info "Connecting to #{from_node}"
    {:noreply, %{state | nodes: [from_node | state.nodes]}}
  end
end
