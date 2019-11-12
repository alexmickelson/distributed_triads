defmodule LoadFileTest do
  use ExUnit.Case
  # doctest DistributedTriads
  alias DistributedTriads.Storage
  alias DistributedTriads.LoadFile

  describe "process_words/2" do
    test "process words creates correct triads" do
      Storage.start_link()
      input = ["this", "is", "a", "sentence"]
      LoadFile.process_words(input)
      Storage.wait_for("is", "a")

      assert ["a"] == Storage.get_values("this", "is")
      assert ["sentence"] == Storage.get_values("is", "a")
    end

    test "handles duplicate inputs" do
      Storage.start_link()
      input = ["this", "is", "a", "this", "is", "other", "thing"]
      LoadFile.process_words(input)
      Storage.wait_for("is", "other")

      assert "a" in Storage.get_values("this", "is")
      assert "other" in Storage.get_values("this", "is")
    end
  end
end
