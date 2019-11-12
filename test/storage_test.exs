defmodule StorageTest do
  use ExUnit.Case
  # doctest DistributedTriads
  alias DistributedTriads.Storage

  test "starting GenServer throws no errors" do
    assert {:ok, _} = Storage.start_link()
  end

  describe "store/2" do
    test "storing doesn't throw an error" do
      Storage.start_link()
      assert :ok = Storage.store("some", "key", "a value")
    end
  end

  test "wait_for waits for key to exist before returning" do
    value = "my value"
    key1 = "my"
    key2 = "key"
    Storage.start_link()
    Storage.store(key1, key2, value)

    task = Task.async(fn ->
      Storage.wait_for(key1, key2)
    end)
    timeout = 1000
    result = Task.await(task, timeout)

    assert result == :ok
  end

  describe "get_values" do
    test "getting from a list of one get the value" do
      value = "my value"
      key1 = "my"
      key2 = "key"
      Storage.start_link()
      Storage.store(key1, key2, value)
      Storage.wait_for(key1, key2)

      actual = Storage.get_values(key1, key2)
      assert actual == [value]
    end

    test "can get list of two values" do
      value = "my value"
      key1 = "my"
      key2 = "key"
      value2 = "my value2"
      Storage.start_link()
      Storage.store(key1, key2, value)
      Storage.store(key1, key2, value2)
      Storage.wait_for(key1, key2)

      actual = Storage.get_values(key1, key2)
      assert value in actual and value2 in actual
      assert length(actual) == 2
    end
  end

  test "get random value get value back" do
    value = "my value"
    key1 = "my"
    key2 = "key"
    Storage.start_link()
    Storage.store(key1, key2, value)
    Storage.wait_for(key1, key2)

    actual = Storage.get_random_value(key1, key2)
    assert actual == value
  end
end
