require "http/client"
require "digest"

class HTTP::Client
  private def exec_internal(request : HTTP::Request)
    cassette_name = VCR.cassette_name

    # If we do not have a cassette_name, perform a normal request
    if (cassette_name.nil?)
      request.to_io(socket)
      socket.flush
      return HTTP::Client::Response.from_io(socket, request.ignore_body?)
    end

    # Create an md5 for the request
    req_md5 = Digest::MD5.hexdigest(request.to_json)

    # Create path vars
    cassette_dir = File.join(VCR.settings.cassette_library_dir, cassette_name)

    # Create a dir for our cassette
    FileUtils.mkdir(cassette_dir) unless (Dir.exists?(cassette_dir))
    cassette_path = File.join(cassette_dir, "#{VCR.sequence}.#{req_md5}.vcr")

    # If it exists, load and return the data
    if File.exists?(cassette_path)
      HTTP::Client::Response.from_io(File.open(cassette_path))
    else
      request.to_io(socket)
      socket.flush
      response = HTTP::Client::Response.from_io(socket, request.ignore_body?)

      cassette_file = File.open(cassette_path, "w+")
      response.to_io(cassette_file)
      cassette_file.flush

      response
    end
  end
end
