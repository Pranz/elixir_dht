defmodule DHT.Node do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, %{
          nodes: []})
  end

end
