defmodule EtsTest do
  use ExUnit.Case
  # doctest DistributedTriads

  test "can create table with key value" do
    name = :ets.new(:table_name, [:named_table, :set, :protected])
    assert name == :table_name
  end

  test "storing two values for a key works" do
    :ets.new(:table_name, [:named_table, :duplicate_bag, :protected])
    :ets.insert(:table_name, {"key", "value"})
    :ets.insert(:table_name, {"key", "value2"})

    expected = [{"key", "value"}, {"key", "value2"}]
    actual = :ets.lookup(:table_name, "key")
    assert expected == actual
  end

  test "can get list of values for a key" do
    :ets.new(:table_name, [:named_table, :duplicate_bag, :protected])
    :ets.insert(:table_name, {"key", "value"})
    :ets.insert(:table_name, {"key", "value2"})

    filter = {"key",:"$1"}
    # filter = [{{:"$1", :"$2"}, [{:==, :"$1", "key"}], [:"$2"]}]
    actual = :ets.match(:table_name, filter)
    expected = [["value"], ["value2"]]

    assert actual == expected
  end
end
