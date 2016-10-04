defmodule DHT do
  require Logger
  use Application
  alias DHT.Bucket

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    Logger.info "Main app started"

    children = [
      supervisor(Task.Supervisor, [[name: :client_connection]]),
      worker(Task, [DHT.Node, :listen, [4040]]),
      worker(DHT.Bucket, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    opts = [strategy: :one_for_one, name: DHT.Supervisor]
    status = Supervisor.start_link(children, opts)

    Bucket.put(1, 3)
    Bucket.put(2, 4)
    Bucket.put(3, 7)
    status
  end
end