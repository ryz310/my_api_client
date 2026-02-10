# Error Handling

## Basic Rules

```ruby
class ExampleApiClient < MyApiClient::Base
  endpoint 'https://example.com'

  error_handling status_code: 400..499, raise: MyApiClient::ClientError
  error_handling status_code: 500..599, raise: MyApiClient::ServerError
end
```

Matchers support:

- `status_code`: `Integer`, `Range`, `Regexp`, `Symbol`
- `headers`: `Hash` values with `String` or `Regexp`
- `json`: `Hash` values with `String`, `Integer`, `Range`, `Regexp`, `Symbol`

## Custom Processing

Use a block:

```ruby
error_handling status_code: 500..599, raise: MyApiClient::ServerError do |params, logger|
  logger.warn "Response Body: #{params.response&.body.inspect}"
end
```

Or use `with:` to call an instance method:

```ruby
error_handling json: { '$.errors.code': 10..19 }, with: :log_error
```

## `forbid_nil`

```ruby
error_handling status_code: 200, json: :forbid_nil
```

Useful when an empty response body should be treated as an error.

## Error Object (`MyApiClient::Error`)

All gem-specific errors inherit `MyApiClient::Error` and expose `#params`.

```ruby
begin
  api_client.get_users(condition: 'john')
rescue MyApiClient::Error => e
  e.params.request
  e.params.response
end
```

`e.params.metadata` (or `e.metadata`) is useful for external logging tools.
