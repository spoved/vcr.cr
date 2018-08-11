require "http/request"

class HTTP::Request
  def to_json
    {
      method:       method,
      host:         host,
      resource:     resource,
      headers:      headers.to_h,
      body:         body.to_s,
      query_params: query_params.to_h,
    }.to_json
  end
end
