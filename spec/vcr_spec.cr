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

  it "switches cassette_dir when new cassette is loaded" do
    load_cassette("cassette-one") do
      VCR.cassette_dir.should eq "spec/fixtures/vcr/cassette-one"
    end

    load_cassette("cassette-two") do
      VCR.cassette_dir.should eq "spec/fixtures/vcr/cassette-two"
    end

    load_cassette("cassette-three")
    VCR.cassette_dir.should eq "spec/fixtures/vcr/cassette-three"
  end

  describe "HTTP::Request#to_json" do
    it "returns a json string with IO body" do
      file = File.open("spec/fixtures/test.txt")
      headers = HTTP::Headers.new
      headers["Content-Type"] = "text/plain"
      request = HTTP::Request.new("POST", "http://httpbin.org/post", headers, file)
      request.to_json.should eq("{\"method\":\"POST\",\"host\":null,\"resource\":\"http://httpbin.org/post\",\"headers\":{\"Content-Type\":[\"text/plain\"]},\"body\":\"hello crystal\\n\",\"query_params\":{}}")
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
