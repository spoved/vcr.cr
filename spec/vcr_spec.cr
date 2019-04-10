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
end
