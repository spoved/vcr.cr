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
    setting filter_sensitive_data : Hash(String, String) = Hash(String, String).new
  end

  # The name of the cassette
  def cassette_name
    @@cassette_name
  end

  def cassette_dir
    @@cassette_dir ||= File.join(VCR.settings.cassette_library_dir, cassette_name.not_nil!)
  end

  # The current sequence, calling this will increment the value
  def sequence
    @@sequence += 1
  end

  # Returns true if the casset should record requests in order
  def in_order?
    @@in_order
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

  def filter_sensitive_data(param_name : String, placeholder : String)
    VCR.settings.filter_sensitive_data[param_name] = placeholder
  end

  def filter_sensitive_data!(request : HTTP::Request) : HTTP::Request
    secured_req = request.dup
    secured_req.query = request.query.dup
    secured_req.headers = request.headers.dup

    VCR.settings.filter_sensitive_data.each do |param, placeholder|
      secured_req.query_params[param] = placeholder if secured_req.query_params[param]?
      secured_req.headers[param] = placeholder if secured_req.headers[param]?
    end
    secured_req
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
