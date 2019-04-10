require "http/client"
require "digest"

class HTTP::Client
  private def orig_exec_internal_single(request)
    decompress = send_request(request)
    return HTTP::Client::Response.from_io?(socket, ignore_body: request.ignore_body?, decompress: decompress)
  end

  private def exec_internal_single(request)
    cassette_name = VCR.cassette_name

    # If we do not have a cassette_name, perform a normal request
    if (cassette_name.nil?)
      return orig_exec_internal_single(request)
    else
      # Create an md5 for the request
      req_md5 = Digest::MD5.hexdigest(request.to_json)

      # Make the casset lib if it doesnt exist
      unless Dir.exists?(VCR.settings.cassette_library_dir)
        Dir.mkdir_p(VCR.settings.cassette_library_dir)
      end

      # Create path vars
      cassette_dir = File.join(VCR.settings.cassette_library_dir, cassette_name)

      # Create a dir for our cassette
      FileUtils.mkdir(cassette_dir) unless (Dir.exists?(cassette_dir))

      # Make file name based on if this cassette should be tracked in order
      file_name = VCR.in_order? ? "#{VCR.sequence}.#{req_md5}.vcr" : "#{req_md5}.vcr"
      cassette_path = File.join(cassette_dir, file_name)

      # If it exists, load and return the data
      if File.exists?(cassette_path)
        HTTP::Client::Response.from_io(File.open(cassette_path))
      else
        response = orig_exec_internal_single(request)
        unless response.nil?
          cassette_file = File.open(cassette_path, "w+")
          response.to_io(cassette_file)
          cassette_file.flush

          return response
        end
      end
    end
  end
end
