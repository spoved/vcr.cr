require "habitat"
require "./ext/*"
require "./vcr/*"

# TODO: Write documentation for `VCR`
module VCR
  extend self

  @@sequence = 0

  Habitat.create do
    setting cassette_library_dir : String = "spec/fixtures/vcr"
  end

  # The name of the cassette
  def cassette_name
    @@cassette_name
  end

  # The current sequence, calling this will increment the value
  def sequence
    @@sequence += 1
  end

  def use_cassette(cassette_name : String, *args, &block)
    @@cassette_name = cassette_name
    @@sequence = 0

    reset_cassette(cassette_name) if args.includes?(:record)

    block.call
    reset!
  end

  # Method to reset class variables. Called at the end of every `use_cassette` method
  private def reset!
    @@cassette_name = nil
    @@sequence = 0
  end

  private def reset_cassette(cassette)
    dir = File.join(VCR.settings.cassette_library_dir, cassette)
    Dir.open(dir).each do |file|
      if file =~ /\.vcr$/
        File.delete(File.join(dir, file))
      end
    end
  end
end
