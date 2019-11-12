defmodule DistributedTriads.Storage do
  use GenServer
  require Logger

  @table :table_name

  ## Client API

  @doc """
  Starts the storage process with GenServer
  """
  def start_link() do
    # 1. Pass the name to GenServer's init
    GenServer.start_link(__MODULE__, @table, name: __MODULE__)
  end

  def lookup(server, name) do
    # 2. Lookup is now done directly in ETS, without accessing the server
    case :ets.lookup(server, name) do
      [{^name, pid}] -> {:ok, pid}
      [] -> :error
    end
  end

  def store(firstWord, secondWord, thirdWord) do
    GenServer.cast(__MODULE__, {:post, firstWord, secondWord, thirdWord})
  end


  def init(table) do
    Logger.debug "#{inspect self() }: Triad Storage started with #{table}"
    name = :ets.new(@table, [:named_table, :duplicate_bag, :protected])
    {:ok, {name, table}}
  end

  def get_random_value(firstWord, secondWord) do
    get_values(firstWord, secondWord)
    |> Enum.random
  end

  def get_values(firstWord, secondWord) do
    values = :ets.match_object(@table, {firstWord, secondWord, :"$1"})
    Enum.map(values, fn {_, _, value} -> value end)
  end

  def wait_for(key1, key2) do
    case :ets.match_object(@table, {key1, key2, :"$1"}) do
      [] ->
        :timer.sleep(1)
        wait_for(key1, key2)
      _ -> :ok
    end
  end

  def handle_cast({:post, key1, key2, value}, _from) do
    result = :ets.insert(@table, {key1, key2, value})
    {:noreply, result}
  end
end
