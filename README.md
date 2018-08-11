# vcr

VCR for Crystal!

Record your test suite's HTTP interactions and replay them during future test runs for fast, deterministic, accurate tests.

Example reduction in test time with over 2k RESTful requests:

* Without VCR
```
Finished in 10:22 minutes
18 examples, 0 failures, 0 errors, 0 pending
```

* With VCR
```
Finished in 13.05 seconds
18 examples, 0 failures, 0 errors, 0 pending
```


## Installation

Add this to your application's `shard.yml`:

```yaml
development_dependencies:
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

- [kalinon](https://github.com/kalinon) Holden Omans - creator, maintainer
