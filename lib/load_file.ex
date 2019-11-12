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

  def process_words([first, second, third | rest]) do
    Storage.store(first, second, third)
    process_words([second, third | rest])
  end

  def process_words([_second_to_last_word, _last_word]) do
    :ok
  end
end
