defmodule DHT.BucketTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, bucket} = DHT.Bucket.start_link
    {:ok, bucket: bucket}
  end
  
  test "store", %{bucket: bucket} do
    assert DHT.Bucket.get(bucket, 1) == nil

    DHT.Bucket.put(bucket, 1, 3)
    assert DHT.Bucket.get(bucket, 1) == 3
  end

  test "pop", %{bucket: bucket} do
    DHT.Bucket.put(bucket, 1, 5)
    assert DHT.Bucket.pop(bucket, 1) == 5
    assert DHT.Bucket.get(bucket, 1) == nil
  end
end
