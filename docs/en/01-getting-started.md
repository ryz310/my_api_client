# Getting Started

## Installation

```ruby
gem 'my_api_client'
```

## Rails Generator

```sh
rails g api_client path/to/resource get:path/to/resource --endpoint https://example.com
```

This generates:

- `app/api_clients/application_api_client.rb`
- `app/api_clients/path/to/resource_api_client.rb`
- `spec/api_clients/path/to/resource_api_client_spec.rb`

## Minimal Class

```ruby
class ApplicationApiClient < MyApiClient::Base
  endpoint 'https://example.com/v1'
end
```

Define shared endpoint, logger, and common error handling in this base class.
