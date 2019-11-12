defmodule DistributedTriads.SentenceGenerator do
  alias DistributedTriads.Storage


  def make_sentence(word1, word2, count \\ 0) do
    "#{word1} #{word2}#{do_make_sentence(word1, word2, count)}"
  end

  def do_make_sentence(_word1, _word2, count) when count < 1 do
    ""
  end

  def do_make_sentence(word1, word2, count) do
    case Storage.get_random_value(word1, word2) do
      word3 when is_binary(word3) ->
        count = caluclate_remaining_sentences(word3, count)
        " #{word3}#{do_make_sentence(word2, word3, count)}"
      _ ->
        ""
    end
  end

  def caluclate_remaining_sentences(word, count) do
    case String.ends_with?(word, ".") do
      false -> count
      true -> count-1
    end
  end
end
