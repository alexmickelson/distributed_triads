defmodule SentenceGeneratorTest do
  use ExUnit.Case
  # doctest DistributedTriads
  alias DistributedTriads.Storage
  alias DistributedTriads.SentenceGenerator

  describe "process_words/2" do
    test "process words creates correct triads" do
      input = ["this", "is", "a", "sentence."]
      Storage.start_link()
      Storage.store(Enum.at(input, 0), Enum.at(input, 1), Enum.at(input, 2))
      Storage.store(Enum.at(input, 1), Enum.at(input, 2), Enum.at(input, 3))
      Storage.wait_for(Enum.at(input, 1), Enum.at(input, 2))

      expected = "this is a sentence."
      actual = SentenceGenerator.make_sentence(Enum.at(input, 0), Enum.at(input, 1) ,1)
      assert actual == expected
    end

    test "process words makes 2 sentences, then stops" do
      input = ["this", "is", "a", "sentence.", "and", "another.", "bad"]
      Storage.start_link()
      Storage.store(Enum.at(input, 0), Enum.at(input, 1), Enum.at(input, 2))
      Storage.store(Enum.at(input, 1), Enum.at(input, 2), Enum.at(input, 3))
      Storage.store(Enum.at(input, 2), Enum.at(input, 3), Enum.at(input, 4))
      Storage.store(Enum.at(input, 3), Enum.at(input, 4), Enum.at(input, 5))
      Storage.store(Enum.at(input, 4), Enum.at(input, 5), Enum.at(input, 6))
      Storage.wait_for(Enum.at(input, 4), Enum.at(input, 5))

      expected = "this is a sentence. and another."
      actual = SentenceGenerator.make_sentence(Enum.at(input, 0), Enum.at(input, 1) ,2)
      assert actual == expected
    end
  end
end
