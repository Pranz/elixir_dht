defmodule DHT.BucketTest do
  use ExUnit.Case, async: true

  test "store", _ do
    DHT.Bucket.put(1, 3)
    assert DHT.Bucket.get(1) == 3
  end

  test "pop", _ do
    DHT.Bucket.put(1, 5)
    assert DHT.Bucket.pop(1) == 5
    assert DHT.Bucket.get(1) == :no_value_for_key
  end
end
