require "http/request"
require "json"

class HTTP::Request
  def to_json
    {
      method:       method,
      host:         hostname,
      resource:     resource,
      headers:      headers.to_h,
      body:         body.to_s,
      query_params: query_params.to_h,
    }.to_json
  end
end
