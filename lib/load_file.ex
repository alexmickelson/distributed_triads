defmodule DistributedTriads.LoadFile do
  alias DistributedTriads.Storage

  def load_file_into_storage(file_path) when is_binary(file_path) do
    File.read(file_path)
    |> string_to_list
    |> process_words
  end

  def string_to_list({:ok, string}) when is_binary(string) do
    String.split(string)
  end

  def string_to_list(_) do
    {:error, "must provide a string"}
  end

  def process_words({:error, message}) do
    {:error, message}
  end

  def process_words(list, _first \\ "");
  def process_words([first, second, third | rest], _) do
    Storage.store(first, second, third)
    process_words([second, third | rest], first)
  end

  def process_words([second_to_last_word, _last_word], third_to_last) do
    Storage.wait_for(third_to_last, second_to_last_word)
    :ok
  end
end
