[![CircleCI](https://circleci.com/gh/ryz310/my_api_client.svg?style=svg)](https://circleci.com/gh/ryz310/my_api_client)
[![Gem Version](https://badge.fury.io/rb/my_api_client.svg)](https://badge.fury.io/rb/my_api_client)
[![Maintainability](https://api.codeclimate.com/v1/badges/861a2c8f168bbe995107/maintainability)](https://codeclimate.com/github/ryz310/my_api_client/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/861a2c8f168bbe995107/test_coverage)](https://codeclimate.com/github/ryz310/my_api_client/test_coverage)

日本語ドキュメントは [README.jp.md](README.jp.md)

# MyApiClient

`my_api_client` is a Ruby API client builder for Rails and plain Ruby apps.
It is based on Sawyer + Faraday and adds:

- easy request DSL (`get`, `post`, `patch`, `put`, `delete`, `pageable_get`)
- flexible response-based error handling DSL (`error_handling`)
- retry/discard hooks (`retry_on`, `discard_on`)
- RSpec helpers and custom matchers for testing

## Supported Versions

- Ruby: 3.1, 3.2, 3.3
- Rails: 6.1, 7.0, 7.1, 7.2

## Installation

```ruby
gem 'my_api_client'
```

For Rails, you can generate a starter class:

```sh
rails g api_client path/to/resource get:path/to/resource --endpoint https://example.com
```

## Quick Start

```ruby
class ExampleApiClient < MyApiClient::Base
  endpoint 'https://example.com/v1'

  def get_users(condition:)
    get 'users', query: { search: condition }
  end
end

api_client = ExampleApiClient.new
api_client.get_users(condition: 'john')
```

## Docs

- [Getting Started](docs/en/01-getting-started.md)
- [Basic Usage and Pagination](docs/en/02-usage.md)
- [Error Handling](docs/en/03-error-handling.md)
- [Retry, Timeout, Logger](docs/en/04-retry-timeout-logger.md)
- [RSpec Helpers and Matchers](docs/en/05-rspec.md)
- [Development and Release](docs/en/06-development.md)

## Contributing

Bug reports and pull requests are welcome on GitHub:
<https://github.com/ryz310/my_api_client>

## License

Available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Please follow the [code of conduct](CODE_OF_CONDUCT.md).
