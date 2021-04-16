require "./spec_helper"

describe VCR do
  # TODO: Write tests

  it "works" do
    direct_resp = Halite.get("https://jsonplaceholder.typicode.com/todos/1").parse
    direct_resp["id"].as_i.should eq 1

    load_cassette("cassette-one") do
      casset_resp = Halite.get("https://jsonplaceholder.typicode.com/todos/1").parse
      casset_resp["id"].as_i.should eq 1
    end
  end

  describe "#filter_sensitive_data!" do
    headers = HTTP::Headers.new
    headers["Authorization"] = "Bearer 123"
    request = HTTP::Request.new("GET", "/?api_key=123", headers: headers)

    it "should replace sensitive data in query params" do
      VCR.filter_sensitive_data("api_key", "<API_KEY>")
      secured_request = VCR.filter_sensitive_data!(request)

      secured_request.query_params["api_key"].should eq("<API_KEY>")
      request.query_params["api_key"].should eq("123")
    end

    it "should replace sensitive data in headers" do
      VCR.filter_sensitive_data("Authorization", "Bearer <TOKEN>")
      secured_request = VCR.filter_sensitive_data!(request)

      secured_request.headers["Authorization"].should eq("Bearer <TOKEN>")
      request.headers["Authorization"].should eq("Bearer 123")
    end
  end
end
