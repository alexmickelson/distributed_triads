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

  @doc """
  Looks up the bucket pid for `name` stored in `server`.

  Returns `{:ok, pid}` if the bucket exists, `:error` otherwise.
  """
  def lookup(server, name) do
    # 2. Lookup is now done directly in ETS, without accessing the server
    case :ets.lookup(server, name) do
      [{^name, pid}] -> {:ok, pid}
      [] -> :error
    end
  end

  def store(key, value) do
    GenServer.cast(__MODULE__, {:post, key, value})
  end


  def init(table) do
    Logger.debug "#{inspect self() }: Triad Storage started with #{table}"
    name = :ets.new(@table, [:named_table, :duplicate_bag, :protected])
    {:ok, {name, table}}
  end

  def get_values(key) do
    values = :ets.lookup(@table, key)
    Enum.map(values, fn {_, value} -> value end)
  end

  def wait_for(key) do
    case :ets.lookup(@table, key) do
      [] ->
        :timer.sleep(1)
        wait_for(key)
      _ -> :ok
    end
  end

  def handle_cast({:post, key, value}, _from) do
    result = :ets.insert(@table, {key, value})
    {:noreply, result}
  end

  # 4. The previous handle_call callback for lookup was removed

  # def handle_cast({:create, name}, {names, refs}) do
  #   # 5. Read and write to the ETS table instead of the map
  #   case lookup(names, name) do
  #     {:ok, _pid} ->
  #       {:noreply, {names, refs}}
  #     :error ->
  #       {:ok, pid} = DynamicSupervisor.start_child(KV.BucketSupervisor, KV.Bucket)
  #       ref = Process.monitor(pid)
  #       refs = Map.put(refs, ref, name)
  #       :ets.insert(names, {name, pid})
  #       {:noreply, {names, refs}}
  #   end
  # end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    # 6. Delete from the ETS table instead of the map
    {name, refs} = Map.pop(refs, ref)
    :ets.delete(names, name)
    {:noreply, {names, refs}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
