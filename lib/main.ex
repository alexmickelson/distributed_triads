defmodule Commandline.CLI do
  alias DistributedTriads.LoadFile
  alias DistributedTriads.SentenceGenerator
  alias DistributedTriads.Storage
  def main(opts \\ []) do
    {options, _, _} = OptionParser.parse(opts,
      switches: [file: :string, sentences: :integer]
    )
    # :rand.uniform(10)
    text_file = Keyword.get(options, :file, "shakespeare.txt")
    num_sentence = Keyword.get(options, :sentences, 1)

    {microseconds, text} = :timer.tc(Commandline.CLI, :do_main, [text_file, num_sentence])

    IO.inspect text
    IO.inspect "seconds: #{microseconds/1_000_000}"
  end

  def do_main(text_file, num_sentence) do
    Storage.start_link()
    LoadFile.load_file_into_storage(text_file)
    SentenceGenerator.make_sentence("I", "have", num_sentence)
  end

end
