defmodule DHT.Bucket do
  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def get(key) do
    Agent.get(__MODULE__, &Map.get(&1, key))
  end

  def put(key, value) do
    Agent.update(__MODULE__, &Map.put(&1, key, value))
  end

  def pop(key) do
    Agent.get_and_update(__MODULE__, &Map.pop(&1, key))
  end

  def exec_tuple_command(command) do
    case command do
      {:get, key} -> get(key)
      {:set, key, value} -> put(key, value)
      {:pop, key} -> pop(key)
      {:error, err} -> {:error, err}
    end
  end
end
