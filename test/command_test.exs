defmodule DHT.CommandTest do
  use ExUnit.Case, async: true
  alias DHT.Command, as: C

  test "parse SET", _ do
    assert(C.parse("set 2 3") == {:set, 2, 3})
  end

  test "parse GET", _ do
    assert(C.parse("get 1") == {:get, 1})
  end

  test "remove trailing and leading spaces", _ do
    assert(C.parse("  get 2 ") == {:get, 2})
  end
end
