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
  def parse(string) do
    tokens = string
    |> String.replace_trailing("\r\n", "")
    |> String.upcase()
    |> String.split(" ")
    IO.puts (is_list(tokens))
    case tokens do
      ["GET", key] -> 
        case Integer.parse(key) do
          {int, _} -> {:get, int}
          _ -> :error
        end
      ["SET", key, value] -> (case {Integer.parse(key), Integer.parse(value)} do
                                {{key, _}, {value, _}} -> {:set, key, value}
                                _ -> :error
                              end)
      _ -> :error
    end
  end
end
