[![CI](https://github.com/ryz310/my_api_client/actions/workflows/ci.yml/badge.svg)](https://github.com/ryz310/my_api_client/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/my_api_client.svg)](https://badge.fury.io/rb/my_api_client)
[![Maintainability](https://qlty.sh/gh/ryz310/projects/my_api_client/maintainability.svg)](https://qlty.sh/gh/ryz310/projects/my_api_client)
[![Code Coverage](https://qlty.sh/gh/ryz310/projects/my_api_client/coverage.svg)](https://qlty.sh/gh/ryz310/projects/my_api_client)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/ryz310/my_api_client)

# MyApiClient

This gem is an API client builder that provides generic functionality for defining API request classes. Its architecture is based on [Sawyer](https://github.com/lostisland/sawyer) and [Faraday](https://github.com/lostisland/faraday), with enhanced error-handling features.

Sawyer can be difficult for generating dummy data and may conflict with other gems in some cases, so this project may reduce direct Sawyer dependency in the future.

It is primarily designed for Ruby on Rails, but it also works in other environments. If you find any issues, please report them on the Issues page.

[toc]

## Supported Versions

- Ruby 3.2, 3.3, 3.4, 4.0
- Rails 7.2, 8.0, 8.1

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'my_api_client'
```

If you are using Ruby on Rails, you can use the generator.

```sh
$ rails g api_client path/to/resource get:path/to/resource --endpoint https://example.com

create  app/api_clients/application_api_client.rb
create  app/api_clients/path/to/resource_api_client.rb
invoke  rspec
create    spec/api_clients/path/to/resource_api_client_spec.rb
```

## Usage

### Basic

The simplest usage example is shown below:

```ruby
class ExampleApiClient < MyApiClient::Base
  endpoint 'https://example.com/v1'

  attr_reader :access_token

  def initialize(access_token:)
    @access_token = access_token
  end

  # GET https://example.com/v1/users
  #
  # @return [Sawyer::Resource] HTTP resource parameter
  def get_users
    get 'users', headers: headers, query: { key: 'value' }
  end

  # POST https://example.com/v1/users
  #
  # @param name [String] Username to create
  # @return [Sawyer::Resource] HTTP resource parameter
  def post_user(name:)
    post 'users', headers: headers, body: { name: name }
  end

  private

  def headers
    {
      'Content-Type': 'application/json;charset=UTF-8',
      'Authorization': "Bearer #{access_token}",
    }
  end
end

api_client = ExampleApiClient.new(access_token: 'access_token')
api_client.get_users #=> #<Sawyer::Resource>
```

`endpoint` defines the base URL for requests. Each method then adds a relative path. In the example above, `get 'users'` sends `GET https://example.com/v1/users`.

Next, define `#initialize` to set values such as an access token or API key. You can omit it if you do not need any instance state.

Then define methods such as `#get_users` and `#post_user`. Inside those methods, call HTTP helpers like `#get` and `#post`. You can also use `#patch`, `#put`, and `#delete`.

### Pagination

Some APIs include a URL for the next page in the response.

MyApiClient provides `#pageable_get` to treat such APIs as an enumerable. An example is shown below:

```ruby
class MyPaginationApiClient < ApplicationApiClient
  endpoint 'https://example.com/v1'

  # GET pagination?page=1
  def pagination
    pageable_get 'pagination', paging: '$.links.next', headers: headers, query: { page: 1 }
  end

  private

  def headers
    { 'Content-Type': 'application/json;charset=UTF-8' }
  end
end
```

In the example above, the first request is `GET https://example.com/v1/pagination?page=1`. It then continues requesting the URL in `$.links.next` from each response.

For example, in the response below, `$.links.next` points to `"https://example.com/pagination?page=3"`:

```json
{
  "links": {
    "next": "https://example.com/pagination?page=3",
    "previous": "https://example.com/pagination?page=1"
  },
  "page": 2
}
```

`#pageable_get` returns [Enumerator::Lazy](https://docs.ruby-lang.org/ja/latest/class/Enumerator=3a=3aLazy.html), so you can iterate using `#each` or `#next`:

```ruby
api_client = MyPaginationApiClient.new
api_client.pagination.each do |response|
  # Do something.
end

result = api_client.pagination
result.next # => 1st page result
result.next # => 2nd page result
result.next # => 3rd page result
```

Note that `#each` is repeated until the value of `paging` becomes `nil`. You can set the upper limit of pagination by combining with `#take`.

You can also use `#pget` as an alias for `#pageable_get`:

```ruby
# GET pagination?page=1
def pagination
  pget 'pagination', paging: '$.links.next', headers: headers, query: { page: 1 }
end
```

### Error handling

MyApiClient lets you define error handling rules that raise exceptions based on response content. For example:

```ruby
class ExampleApiClient < MyApiClient::Base
  endpoint 'https://example.com'

  error_handling status_code: 400..499,
                 raise: MyApiClient::ClientError

  error_handling status_code: 500..599, raise: MyApiClient::ServerError do |_params, logger|
    logger.warn 'Server error occurred.'
  end

  error_handling json: { '$.errors.code': 10..19 },
                 raise: MyApiClient::ClientError,
                 with: :my_error_handling

  # Omission

  private

  # @param params [MyApiClient::Params::Params] HTTP request and response params
  # @param logger [MyApiClient::Request::Logger] Logger for a request processing
  def my_error_handling(params, logger)
    logger.warn "Response Body: #{params.response.body.inspect}"
  end
end
```

Let's go through each option. First, this rule checks `status_code`:

```ruby
error_handling status_code: 400..499, raise: MyApiClient::ClientError
```

This raises `MyApiClient::ClientError` when the response status code is in `400..499` for requests from `ExampleApiClient`. Error handling rules are also inherited by child classes.

You can specify `Integer`, `Range`, or `Regexp` for `status_code`.

A class inheriting from `MyApiClient::Error` can be specified for `raise`. See [here](https://github.com/ryz310/my_api_client/blob/master/lib/my_api_client/errors) for built-in error classes. If `raise` is omitted, `MyApiClient::Error` is raised.

Next, here is an example using a block:

```ruby
error_handling status_code: 500..599, raise: MyApiClient::ServerError do |_params, logger|
  logger.warn 'Server error occurred.'
end
```

In this example, when the status code is `500..599`, the block runs before `MyApiClient::ServerError` is raised. The `params` argument includes both request and response information.

`logger` is a request-scoped logger. If you log with this instance, request information is automatically included, which is useful for debugging:

```text
API request `GET https://example.com/path/to/resource`: "Server error occurred."
```

```ruby
error_handling json: { '$.errors.code': 10..19 }, with: :my_error_handling
```

For `json`, use [JSONPath](https://goessner.net/articles/JsonPath/) as the hash key, extract values from response JSON, and match them against expected values. You can specify `String`, `Integer`, `Range`, or `Regexp` as matcher values.

In this case, it matches JSON such as:

```json
{
  "errors": {
    "code": 10,
    "message": "Some error has occurred."
  }
}
```

For `headers`, specify a response-header key and match its value. You can specify `String` or `Regexp` as matcher values.

```ruby
error_handling headers: { 'www-authenticate': /invalid token/ }, with: :my_error_handling
```

In this case, it matches response headers such as:

```text
cache-control: no-cache, no-store, max-age=0, must-revalidate
content-type: application/json
www-authenticate: Bearer error="invalid_token", error_description="invalid token"
content-length: 104
```

By specifying an instance method name in `with`, you can run arbitrary logic before raising an exception. The method receives `params` and `logger`, just like a block. Note that `block` and `with` cannot be used together.

```ruby
# @param params [MyApiClient::Params::Params] HTTP req and res params
# @param logger [MyApiClient::Request::Logger] Logger for a request processing
def my_error_handling(params, logger)
  logger.warn "Response Body: #{params.response.body.inspect}"
end
```

#### Default error handling

By default, MyApiClient treats 4xx and 5xx responses as exceptions. In the 4xx range, it raises an exception class inheriting from `MyApiClient::ClientError`; in the 5xx range, it raises one inheriting from `MyApiClient::ServerError`.

Also, `retry_on` is defined by default for `MyApiClient::NetworkError`.

Both can be overridden, so define `error_handling` as needed.

They are defined [here](https://github.com/ryz310/my_api_client/blob/master/lib/my_api_client/default_error_handlers.rb).

#### Use Symbol

```ruby
error_handling json: { '$.errors.code': :negative? }
```

This is an experimental feature. By specifying a `Symbol` as the value for `status` or `json`, MyApiClient calls that method on the extracted value and uses the result for matching. In the example above, it matches the following JSON. If `#negative?` does not exist on the target object, the method is not called.

#### forbid_nil

```ruby
error_handling status_code: 200, json: :forbid_nil
```

Some services expect a non-empty response body but occasionally receive an empty one. This experimental option, `json: :forbid_nil`, helps detect that case. Normally, an empty response body is not treated as an error, but with this option it is. Be careful of false positives, because some APIs intentionally return empty responses.

#### MyApiClient::Params::Params

`MyApiClient::Params::Params` is a value object that combines request and response details.
An instance of this class is passed to error handlers (`block`/`with`) and is also available from `MyApiClient::Error#params`.

- `#request`: `MyApiClient::Params::Request` (method, URL, headers, and body)
- `#response`: `Sawyer::Response` (or `nil` for network errors)

It also provides `#metadata` (`#to_bugsnag` alias), which merges request/response data into a single hash for logging and error reporting.

```ruby
begin
  api_client.request
rescue MyApiClient::Error => e
  e.params.metadata
  # => {
  #      request_line: "GET https://example.com/v1/users?search=foo",
  #      request_headers: { "Authorization" => "Bearer token" },
  #      response_status: 429,
  #      response_headers: { "content-type" => "application/json" },
  #      response_body: { errors: [{ code: 20 }] },
  #      duration: 0.123
  #    }
end
```

#### MyApiClient::Error

If an API response matches a rule defined in `error_handling`, the exception class specified in `raise` is triggered. This exception class must inherit from `MyApiClient::Error`.

This exception class has a method called `#params`, which allows you to refer to request and response parameters.

```ruby
begin
  api_client.request
rescue MyApiClient::Error => e
  e.params.inspect
  # => {
  #      :request=>"#<MyApiClient::Params::Request#inspect>",
  #      :response=>"#<Sawyer::Response#inspect>",
  #    }
end
```

#### Bugsnag breadcrumbs

If you are using [Bugsnag-Ruby v6.11.0](https://github.com/bugsnag/bugsnag-ruby/releases/tag/v6.11.0) or later, the [breadcrumbs feature](https://docs.bugsnag.com/platforms/ruby/other/#logging-breadcrumbs) is supported automatically. When `MyApiClient::Error` occurs, `Bugsnag.leave_breadcrumb` is called internally, so you can inspect request and response details in the Bugsnag console.

### Retry

Next, let's look at retry support in MyApiClient.

```ruby
class ExampleApiClient < MyApiClient::Base
  endpoint 'https://example.com'

  retry_on MyApiClient::NetworkError, wait: 0.1.seconds, attempts: 3
  retry_on MyApiClient::ApiLimitError, wait: 30.seconds, attempts: 3

  error_handling json: { '$.errors.code': 20 }, raise: MyApiClient::ApiLimitError
end
```

When an API request is executed many times, network errors can occur. Sometimes the network is unavailable for a long time, but often the error is temporary. In MyApiClient, network-related exceptions are wrapped as `MyApiClient::NetworkError`. Using `retry_on`, you can handle such exceptions and retry requests with configurable wait time and attempt count, similar to `ActiveJob`.

`retry_on MyApiClient::NetworkError` is enabled by default, so you do not need to define it unless you want custom `wait` or `attempts` values.

Unlike `ActiveJob`, retries are performed synchronously. In practice, this is most useful for short-lived network interruptions. You can also retry for API rate limits as in the example above, but handling that with `ActiveJob` may be a better fit depending on your workload.

`discard_on` is also implemented, but details are omitted here because a strong use case has not been identified yet.

#### Convenient usage

You can omit the definition of `retry_on` by adding the `retry` option to `error_handling`.
For example, the following two codes have the same meaning:

```ruby
retry_on MyApiClient::ApiLimitError, wait: 30.seconds, attempts: 3
error_handling json: { '$.errors.code': 20 },
               raise: MyApiClient::ApiLimitError
```

```ruby
error_handling json: { '$.errors.code': 20 },
               raise: MyApiClient::ApiLimitError,
               retry: { wait: 30.seconds, attempts: 3 }
```

If you do not need to specify `wait` or `attempts` in `retry_on`, you can use `retry: true`:

```ruby
error_handling json: { '$.errors.code': 20 },
               raise: MyApiClient::ApiLimitError,
               retry: true
```

Keep the following in mind when using the `retry` option:

- The `raise` option must be specified for `error_handling`
- Definition of `error_handling` using `block` is prohibited

#### MyApiClient::NetworkError

As mentioned above, MyApiClient wraps network exceptions as `MyApiClient::NetworkError`. Like other client errors, its parent class is `MyApiClient::Error`. The list of wrapped exception classes is available in `MyApiClient::NETWORK_ERRORS`. You can inspect the original exception via `#original_error`:

```ruby
begin
  api_client.request
rescue MyApiClient::NetworkError => e
  e.original_error # => #<Net::OpenTimeout>
  e.params.response # => nil
end
```

Unlike normal API errors that are raised after receiving a response, this exception is raised during request execution. Therefore, the exception instance does not include response parameters.

### Timeout

You can configure HTTP timeout values per API client class:

```ruby
class ApplicationApiClient < MyApiClient::Base
  http_open_timeout 2.seconds
  http_read_timeout 3.seconds
end
```

- `http_open_timeout`: maximum wait time to open a connection
- `http_read_timeout`: maximum wait time for each HTTP read

Internally, these are passed to Faraday request options as `open_timeout` and `timeout`.
If a timeout occurs, it is wrapped and raised as `MyApiClient::NetworkError`.

### Logger

Each API client class has a configurable logger (`self.logger`).
By default, MyApiClient uses `Logger.new($stdout)`, and in Rails apps you typically set:

```ruby
class ApplicationApiClient < MyApiClient::Base
  self.logger = Rails.logger
end
```

MyApiClient wraps this logger with `MyApiClient::Request::Logger` and prefixes messages with request information:

```text
API request `GET https://example.com/v1/users`: "Start"
API request `GET https://example.com/v1/users`: "Duration 100.0 msec"
API request `GET https://example.com/v1/users`: "Success (200)"
```

On failure, it logs:

```text
API request `GET https://example.com/v1/users`: "Failure (Net::OpenTimeout)"
```

## One request for one class

In many cases, APIs on the same host share request headers and error structures, so defining multiple endpoints in one class is practical. If you prefer API-level separation, you can also use a "one class per API" design:

```ruby
class ExampleApiClient < MyApiClient::Base
  endpoint 'https://example.com'

  error_handling status_code: 400..599

  attr_reader :access_token

  def initialize(access_token:)
    @access_token = access_token
  end

  private

  def headers
    {
      'Content-Type': 'application/json;charset=UTF-8',
      'Authorization': "Bearer #{access_token}",
    }
  end
end

class GetUsersApiClient < ExampleApiClient
  error_handling json: { '$.errors.code': 10 }, raise: MyApiClient::ClientError

  # GET https://example.com/users
  #
  # @return [Sawyer::Resource] HTTP resource parameter
  def request
    get 'users', query: { key: 'value' }, headers: headers
  end
end

class PostUserApiClient < ExampleApiClient
  error_handling json: { '$.errors.code': 10 }, raise: MyApiClient::ApiLimitError

  # POST https://example.com/users
  #
  # @param name [String] Username to create
  # @return [Sawyer::Resource] HTTP resource parameter
  def request(name:)
    post 'users', headers: headers, body: { name: name }
  end
end
```

## RSpec

### Setup

Supports testing with RSpec.
Add the following code to `spec/spec_helper.rb` (or `spec/rails_helper.rb`):

```ruby
require 'my_api_client/rspec'
```

### Testing

Suppose you have defined an `ApiClient` like this:

```ruby
class ExampleApiClient < MyApiClient::Base
  endpoint 'https://example.com/v1'

  error_handling status_code: 200, json: { '$.errors.code': 10 },
                 raise: MyApiClient::ClientError

  attr_reader :access_token

  def initialize(access_token:)
    @access_token = access_token
  end

  # GET https://example.com/v1/users
  def get_users(condition:)
    get 'users', headers: headers, query: { search: condition }
  end

  private

  def headers
    {
      'Content-Type': 'application/json;charset=UTF-8',
      'Authorization': "Bearer #{access_token}",
    }
  end
end
```

When you define a new API client, these are the two main test targets:

1. It sends the expected HTTP request (method, URL, headers/query/body)
2. It handles error responses as expected (`error_handling`)

MyApiClient provides custom matchers for both.

#### 1. Request assertion (`request_to` + `with`)

Use `request_to` to assert method/URL and `with` to assert `headers`, `query`, or `body`.
`expect` must receive a block.

```ruby
RSpec.describe ExampleApiClient, type: :api_client do
  let(:api_client) { described_class.new(access_token: 'access token') }
  let(:headers) do
    {
      'Content-Type': 'application/json;charset=UTF-8',
      'Authorization': 'Bearer access token',
    }
  end

  describe '#get_users' do
    it do
      expect { api_client.get_users(condition: 'condition') }
        .to request_to(:get, 'https://example.com/v1/users')
        .with(headers: headers, query: { search: 'condition' })
    end
  end
end
```

#### 2. Error handling assertion (`be_handled_as_an_error` + `when_receive`)

Use `be_handled_as_an_error` to assert the raised error class, and `when_receive` to provide mock response input (`status_code`, `headers`, `body`).

```ruby
it do
  expect { api_client.get_users(condition: 'condition') }
    .to be_handled_as_an_error(MyApiClient::ClientError)
    .when_receive(status_code: 200, body: { errors: { code: 10 } }.to_json)
end
```

You can also assert that a response is *not* handled as an error:

```ruby
it do
  expect { api_client.get_users(condition: 'condition') }
    .not_to be_handled_as_an_error(MyApiClient::ClientError)
    .when_receive(status_code: 200, body: { users: [{ id: 1 }] }.to_json)
end
```

If the client has `retry_on`, you can assert retry count with `after_retry(...).times`:

```ruby
it do
  expect { api_client.get_users(condition: 'condition') }
    .to be_handled_as_an_error(MyApiClient::ApiLimitError)
    .after_retry(3).times
    .when_receive(status_code: 200, body: { errors: { code: 20 } }.to_json)
end
```

### Stubbing

Use `stub_api_client_all` or `stub_api_client` to stub API client methods without real HTTP.

#### `response` option

```ruby
class ExampleApiClient < MyApiClient::Base
  endpoint 'https://example.com'

  def request(user_id:)
    get "users/#{user_id}"
  end
end

stub_api_client_all(
  ExampleApiClient,
  request: { response: { id: 12_345 } }
)

response = ExampleApiClient.new.request(user_id: 1)
response.id # => 12345
```

`response` can be omitted as shorthand:

```ruby
stub_api_client_all(
  ExampleApiClient,
  request: { id: 12_345 }
)
```

#### Proc response

You can generate response data from request arguments:

```ruby
stub_api_client_all(
  ExampleApiClient,
  request: ->(params) { { id: params[:user_id] } }
)
```

#### Return value of `stub_api_client_all` / `stub_api_client`

Both methods return a spy object, so you can assert received calls:

```ruby
def execute_api_request
  ExampleApiClient.new.request(user_id: 1)
end

api_client = stub_api_client_all(ExampleApiClient, request: nil)
execute_api_request
expect(api_client).to have_received(:request).with(user_id: 1)
```

#### `raise` option

To test error paths, use the `raise` option:

```ruby
stub_api_client_all(ExampleApiClient, request: { raise: MyApiClient::Error })
expect { ExampleApiClient.new.request(user_id: 1) }.to raise_error(MyApiClient::Error)
```

You can combine `raise`, `response`, and `status_code`:

```ruby
stub_api_client_all(
  ExampleApiClient,
  request: {
    raise: MyApiClient::Error,
    response: { message: 'error' },
    status_code: 429,
  }
)

begin
  ExampleApiClient.new.request(user_id: 1)
rescue MyApiClient::Error => e
  e.params.response.data.to_h # => { message: "error" }
  e.params.response.status    # => 429
end
```

#### `pageable` option

For `#pageable_get` (`#pget`), you can stub page-by-page responses:

```ruby
stub_api_client_all(
  MyPaginationApiClient,
  pagination: {
    pageable: [
      { page: 1 },
      { page: 2 },
      { page: 3 },
    ],
  }
)

MyPaginationApiClient.new.pagination.each do |response|
  response.page #=> 1, 2, 3
end
```

Each page entry supports the same options (`response`, `raise`, `Proc`, etc.).  
You can also pass an `Enumerator` for endless pagination stubs.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

### Integration Specs With Real HTTP

The integration specs under `spec/integrations/api_clients/` call the local `my_api` Rails server via HTTP.

Run with Docker Compose:

```sh
docker compose up -d --build my_api
docker compose run --rm test bundle exec rspec
docker compose down --volumes --remove-orphans
```

Run only integration specs:

```sh
docker compose up -d --build my_api
docker compose run --rm test bundle exec rspec spec/integrations/api_clients
docker compose down --volumes --remove-orphans
```

To install this gem onto your local machine, run `bundle exec rake install`.

## Deployment

This project uses [gem_comet](https://github.com/ryz310/gem_comet) for release automation.

### Preparation

Create `.envrc` and set `GITHUB_ACCESS_TOKEN`:

```sh
cp .envrc.skeleton .envrc
```

Install `gem_comet`:

```sh
gem install gem_comet
```

### Usage

Check PRs merged since the previous release:

```sh
gem_comet changelog
```

Start a release with a new version:

```sh
gem_comet release {VERSION}
```

This creates two PRs:

- `Update v{VERSION}`
- `Release v{VERSION}`

Merge `Update v{VERSION}` first after checking version bump and polishing `CHANGELOG.md`.  
Then verify `Release v{VERSION}` (including CI) and merge it to publish the gem.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ryz310/my_api_client. Reports in Japanese are also welcome. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the MyApiClient project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ryz310/my_api_client/blob/master/CODE_OF_CONDUCT.md).
