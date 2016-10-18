defmodule DHT.UtilTest do
  use ExUnit.Case, async: true
  alias DHT.Util, as: U

  test "count keys with same val", _ do
    assert(U.count_keys_with_same_val(%{
              1 => 6,
              2 => 6,
              3 => 7,
              4 => 8}) == %{
    6 => 2,
    7 => 1,
    8 => 1
  })
  end
end
