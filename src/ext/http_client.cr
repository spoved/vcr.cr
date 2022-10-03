require "http/client"
require "digest"

class HTTP::Client
  {% if compare_versions(Crystal::VERSION, "1.6.0-0") >= 0 %}
    private def orig_exec_internal_single(request, implicit_compression = false)
      send_request(request)
      HTTP::Client::Response.from_io?(io, ignore_body: request.ignore_body?, decompress: implicit_compression)
    end

    private def exec_internal_single(request, implicit_compression = false)
      cassette_name = VCR.cassette_name

      # If we do not have a cassette_name, perform a normal request
      if (cassette_name.nil?)
        orig_exec_internal_single(request, implicit_compression: implicit_compression)
      else
        _vcr_record(request, implicit_compression: implicit_compression)
      end
    end
  {% else %}
    private def orig_exec_internal_single(request)
      decompress = send_request(request)
      HTTP::Client::Response.from_io?(io, ignore_body: request.ignore_body?, decompress: decompress)
    end

    private def exec_internal_single(request)
      cassette_name = VCR.cassette_name

      # If we do not have a cassette_name, perform a normal request
      if (cassette_name.nil?)
        orig_exec_internal_single(request)
      else
        _vcr_record(request)
      end
    end
  {% end %}

  private def _vcr_record(request, implicit_compression = false)
    # Create an md5 for the request
    secured_request = VCR.filter_sensitive_data!(request)
    req_md5 = Digest::MD5.hexdigest(secured_request.to_json)
    cassette_dir = VCR.cassette_dir

    # Create a dir for our cassette
    Dir.mkdir_p(cassette_dir) unless (Dir.exists?(cassette_dir))

    # Make file name based on if this cassette should be tracked in order
    file_name = VCR.in_order? ? "#{VCR.sequence}.#{req_md5}.vcr" : "#{req_md5}.vcr"
    cassette_path = File.join(cassette_dir, file_name)

    # If it exists, load and return the data
    if File.exists?(cassette_path)
      f = File.open(cassette_path)
      begin
        response = HTTP::Client::Response.from_io(f)
      ensure
        f.close
      end
      response
    else
      {% if compare_versions(Crystal::VERSION, "1.6.0-0") >= 0 %}
        response = orig_exec_internal_single(request, implicit_compression: implicit_compression)
      {% else %}
        response = orig_exec_internal_single(request)
      {% end %}

      unless response.nil?
        io = IO::Memory.new
        response.to_io(io)
        io.rewind

        File.write(cassette_path, io)

        return response
      end
    end
  end
end
