defmodule DHT do
  require Logger
  use Application
  alias DHT.Bucket, as: B

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    Logger.info "Main app started"

    B.put(bucket, "1", 3)
    B.put(bucket, "2", 5)
    B.put(bucket, "3", 7)

    children = [
      supervisor(Task.Supervisor, [[name: :client_connection]]),
      worker(Task, [DHT.Node, :listen, [4040]])
      worker(DHT.Bucket, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    opts = [strategy: :one_for_one, name: DHT.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
