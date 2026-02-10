# Retry, Timeout, Logger

## Retry

```ruby
class ExampleApiClient < MyApiClient::Base
  endpoint 'https://example.com'

  error_handling json: { '$.errors.code': 20 },
                 raise: MyApiClient::ApiLimitError,
                 retry: { wait: 30.seconds, attempts: 3 }
end
```

Notes:

- `retry: true` uses default retry options.
- `retry` requires `raise`.
- `retry` cannot be combined with block-style `error_handling`.

`MyApiClient::NetworkError` is retried by default.

## Network Error

`MyApiClient::NetworkError` wraps low-level errors and exposes `#original_error`.

```ruby
begin
  api_client.get_users(condition: 'john')
rescue MyApiClient::NetworkError => e
  e.original_error
  e.params.response # nil
end
```

## Timeout

```ruby
class ExampleApiClient < MyApiClient::Base
  endpoint 'https://example.com'
  http_read_timeout 10
  http_open_timeout 5
end
```

## Logger

```ruby
class ExampleApiClient < MyApiClient::Base
  self.logger = Rails.logger
end
```

Request logs are emitted like:

- `Start`
- `Duration ... msec`
- `Success (...)` or `Failure (...)`
