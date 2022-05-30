require "http/request"
require "json"

class HTTP::Request
  def to_json
    {
      method:       method,
      host:         hostname,
      resource:     resource,
      headers:      headers.to_h,
      body:         body_string,
      query_params: query_params.to_h,
    }.to_json
  end

  def body_string
    if !body.nil? && body.is_a?(File)
      body.as(File).gets_to_end.tap do |_|
        body.as(File).rewind
      end
    else
      body.to_s
    end
  end
end
