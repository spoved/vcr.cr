require "spec"
require "../src/vcr"

require "halite"
require "file_utils"

FileUtils.rm_rf("./spec/fixtures/vcr/cassette-one")
