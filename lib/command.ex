defmodule DHT.Command do
  @doc ~S"""
  Parses the `string` and returns
  {:get, key} |
  {:set, key, value} |
  :error
  
  ## Examples
    iex> DHT.Command.parse "GET 3\r\n"
    {:get, 3}
    iex> DHT.Command.parse "SET 3\r\n"
    {:set, 5}
    iex> DHT.Command.parse "FOO 3\r\n"
    :error
  """
  def parse(string)
end
