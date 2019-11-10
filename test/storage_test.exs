defmodule StorageTes do
  use ExUnit.Case
  # doctest DistributedTriads
  alias DistributedTriads.Storage

  test "starting GenServer throws no errors" do
    assert {:ok, _} = Storage.start_link()
  end

  describe "store/2" do
    test "storing doesn't throw an error" do
      Storage.start_link()
      assert :ok = Storage.store("some key", "a value")
    end
  end

  test "wait_for waits for key to exist before returning" do
    value = "my value"
    key = "my key"
    Storage.start_link()
    Storage.store(key, value)

    task = Task.async(fn ->
      Storage.wait_for(key)
    end)
    timeout = 1000
    result = Task.await(task, timeout)

    assert result == :ok
  end

  describe "get_values" do
    test "getting from a list of one get the value" do
      value = "my value"
      key = "my key"
      Storage.start_link()
      Storage.store(key, value)
      Storage.wait_for(key)

      actual = Storage.get_values(key)
      assert actual == [value]
    end

    test "can get list of two values" do
      value = "my value"
      key = "my key"
      value2 = "my value2"
      Storage.start_link()
      Storage.store(key, value)
      Storage.store(key, value2)
      Storage.wait_for(key)

      actual = Storage.get_values(key)
      assert value in actual and value2 in actual
      assert length(actual) == 2
    end
  end
end
