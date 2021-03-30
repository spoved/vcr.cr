require "http/client"
require "digest"

class HTTP::Client
  private def orig_exec_internal_single(request)
    decompress = send_request(request)
    return HTTP::Client::Response.from_io?(io, ignore_body: request.ignore_body?, decompress: decompress)
  end

  private def exec_internal_single(request)
    cassette_name = VCR.cassette_name

    # If we do not have a cassette_name, perform a normal request
    if (cassette_name.nil?)
      return orig_exec_internal_single(request)
    else
      VCR.record(request)
    end
  end
end
