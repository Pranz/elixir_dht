defmodule DHT.Util do
  def count_keys_with_same_val(map) do
    Enum.reduce(map, %{}, fn({key, val}, acc) ->
      Map.update(acc, val, 1, &(&1 + 1))
    end)
  end
end
