# vcr

VCR for Crystal!

Record your test suite's HTTP interactions and replay them during future test runs for fast, deterministic, accurate tests.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  vcr:
    github: spoved/vcr.cr
```

## Usage

```crystal
require "vcr"
require "http/client"

load_cassette("cassette-one") do
  response = HTTP::Client.get("https://jsonplaceholder.typicode.com/todos/1")
end
```

You can also record multiple requests within a single block:

```crystal
load_cassette("cassette-two") do
  r1 = HTTP::Client.get("https://jsonplaceholder.typicode.com/todos/1")
  r2 = HTTP::Client.get("https://jsonplaceholder.typicode.com/todos/2")
end
```

To easily reset the cassette and record, simply add the `:record` argument:

```crystal
load_cassette("cassette-two", :record) do
  r1 = HTTP::Client.get("https://jsonplaceholder.typicode.com/todos/1")
  r2 = HTTP::Client.get("https://jsonplaceholder.typicode.com/todos/2")
end
```

Customize the location of where the cassettes are stored. The default is `spec/fixtures/vcr`.

```crystal
VCR.configure do
  settings.cassette_library_dir = "/some/path/cassettes"
end
```

## Contributing

1. Fork it (<https://github.com/spoved/vcr.cr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [your-github-user](https://github.com/kalinon) Holden Omans - creator, maintainer
