require "habitat"
require "./ext/*"
require "./vcr/*"

# TODO: Write documentation for `VCR`
module VCR
  extend self

  @@in_order = false
  @@sequence = 0
  @@cassette_dir : String? = nil

  Habitat.create do
    setting cassette_library_dir : String = "spec/fixtures/vcr"
  end

  # The name of the cassette
  def cassette_name
    @@cassette_name
  end

  def cassette_dir
    @@cassette_dir ||= File.join(VCR.settings.cassette_library_dir, cassette_name)
  end

  # The current sequence, calling this will increment the value
  def sequence
    @@sequence += 1
  end

  # Returns true if the casset should record requests in order
  def in_order?
    @@in_order
  end

  def record(request)
    # Create an md5 for the request
    req_md5 = Digest::MD5.hexdigest(request.to_json)

    # Create a dir for our cassette
    Dir.mkdir_p(cassette_dir) unless (Dir.exists?(cassette_dir))

    # Make file name based on if this cassette should be tracked in order
    file_name = in_order? ? "#{sequence}.#{req_md5}.vcr" : "#{req_md5}.vcr"
    cassette_path = File.join(cassette_dir, file_name)

    # If it exists, load and return the data
    if File.exists?(cassette_path)
      f = File.open(cassette_path)
      response = HTTP::Client::Response.from_io(f)
      f.close
      response
    else
      response = orig_exec_internal_single(request)
      unless response.nil?
        io = IO::Memory.new
        response.to_io(io)
        io.rewind

        File.open(cassette_path, "w+") do |f|
          io.each_line do |line|
            f.puts(line) unless line =~ /Content-Encoding: gzip/
          end
        end

        return response
      end
    end
  end

  # Defines the cassette to load for recording. Optional arguments can also be
  # passed.
  #
  # Options:
  # * `:record` - will delete any VCR files in this cassette so new ones can be generated
  # * `:in_order` - will record requests in order (allows multiple records of the same request). Should be used when you expect the result to be different on a second request
  #
  # Example:
  # ```
  # VCR.use_cassette("cassette-one") do
  #   r1 = HTTP::Client.get("https://jsonplaceholder.typicode.com/todos")
  # end
  # ```
  #
  # Record new responses, in order, so i can verify the delete worked
  # ```
  # VCR.use_cassette("cassette-one", :record, :in_order) do
  #   r1 = HTTP::Client.get("https://jsonplaceholder.typicode.com/todos")
  #   HTTP::Client.delete("https://jsonplaceholder.typicode.com/todos/1")
  #   r2 = HTTP::Client.get("https://jsonplaceholder.typicode.com/todos")
  # end
  # ```
  def use_cassette(cassette_name : String, *args, &block)
    use_cassette(cassette_name, *args)

    block.call
    reset!
  end

  def use_cassette(cassette_name : String, *args)
    @@cassette_name = cassette_name
    @@sequence = 0

    @@in_order = args.includes?(:in_order)
    reset_cassette(cassette_name) if args.includes?(:record)
  end

  # Method to reset class variables. Called at the end of every `use_cassette` method
  private def reset!
    @@cassette_name = nil
    @@sequence = 0
    @@in_order = false
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
