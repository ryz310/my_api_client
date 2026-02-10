# RSpec Helpers and Matchers

## Setup

Add to `spec/spec_helper.rb` or `spec/rails_helper.rb`:

```ruby
require 'my_api_client/rspec'
```

## Request Matcher (`request_to`)

```ruby
expect { api_client.get_users(condition: 'john') }
  .to request_to(:get, 'https://example.com/v1/users')
  .with(query: { search: 'john' })
```

## Error Matcher (`be_handled_as_an_error`)

```ruby
expect { api_client.get_users(condition: 'john') }
  .to be_handled_as_an_error(MyApiClient::ClientError)
  .when_receive(status_code: 200, body: { errors: { code: 10 } }.to_json)
```

Retry assertion:

```ruby
expect { api_client.get_users(condition: 'john') }
  .to be_handled_as_an_error(MyApiClient::ApiLimitError)
  .after_retry(3).times
  .when_receive(status_code: 200, body: { errors: { code: 20 } }.to_json)
```

## Stubbing (`stub_api_client`, `stub_api_client_all`)

```ruby
stub_api_client_all(ExampleApiClient, request: { response: { id: 1 } })
ExampleApiClient.new.request(user_id: 10).id # => 1
```

Supported options per action:

- plain hash response
- `response:`
- `raise:` (error class or instance)
- `status_code:` (with `raise:`)
- `pageable:` (Enumerable for pagination)
- `Proc` for dynamic response
