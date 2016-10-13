defmodule DHT do
  require Logger
  use Application
  alias DHT.Bucket

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    Logger.info "Main app started"

    children = [
      supervisor(Task.Supervisor, [[name: :client_connection]]),
      worker(Task, [DHT.Server, :listen, [4040..4100]]),
      worker(DHT.Bucket, []),
      worker(DHT.Node, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    opts = [strategy: :one_for_one, name: DHT.Supervisor]
    status = Supervisor.start_link(children, opts)

    status
  end
end
