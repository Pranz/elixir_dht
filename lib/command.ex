defmodule DHT.Command do
  @doc ~S"""
  Parses the `string` and gives the corresponding command.
  Case insentive. returns
  {:get, key} |
  {:set, key, value} |
  {:pop, key} |
  {:inc, key} |
  {:dec, key} |
  :error
  """
  def parse(string) do
    tokens = tokenize(string)
        case tokens do
      ["GET", key] ->
        case Integer.parse(key) do
          {int, _} -> {:get, int}
          _ -> {:error, :int_expected}
        end
      ["SET", key, value] ->
        case {Integer.parse(key), Integer.parse(value)} do
          {{key, _}, {value, _}} -> {:set, key, value}
          _ -> {:error, :int_expected}
        end
      ["POP", key] ->
        case Integer.parse(key) do
          {int, _} -> {:pop, int}
          _ -> {:error, :int_expected}
        end
      ["INC", key] ->
        case Integer.parse(key) do
          {int, _} -> {:inc, int}
          _ -> {:error, :int_expected}
        end
      ["DEC", key] ->
        case Integer.parse(key) do
          {int, _} -> {:dec, int}
          _ -> {:error, :int_expected}
        end
      _ -> {:error, :unrecognized_command}
    end
  end

  defp tokenize(string) do
    string
    |> String.replace_trailing("\r\n", "")
    |> String.replace_trailing(" ", "")
    |> String.replace_leading(" ", "")
    |> String.upcase()
    |> String.split(" ")
  end
end

