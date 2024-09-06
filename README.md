[![CircleCI](https://circleci.com/gh/ryz310/my_api_client.svg?style=svg)](https://circleci.com/gh/ryz310/my_api_client)
[![Gem Version](https://badge.fury.io/rb/my_api_client.svg)](https://badge.fury.io/rb/my_api_client)
[![Maintainability](https://api.codeclimate.com/v1/badges/861a2c8f168bbe995107/maintainability)](https://codeclimate.com/github/ryz310/my_api_client/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/861a2c8f168bbe995107/test_coverage)](https://codeclimate.com/github/ryz310/my_api_client/test_coverage)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/ryz310/my_api_client)

日本語ドキュメントは [こちら](README.jp.md)

# MyApiClient

This gem is an API client builder. It provides generic functionality for creating API request classes. It has a structure based on [Sawyer](https://github.com/lostisland/sawyer) and [Faraday](https://github.com/lostisland/faraday) with enhanced error handling functions.

It is supposed to be used in Ruby on Rails, but it is made to work in other environments. If you have any problems, please report them from the Issue page.

[toc]

## Supported Versions

- Ruby 3.1, 3.2
- Rails 6.1, 7.0

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'my_api_client'
```

If you are using Ruby on Rails, you can use the `generator` function.

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
  # @param name [String] Username which want to create
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

api_clinet = ExampleApiClient.new(access_token: 'access_token')
api_clinet.get_users #=> #<Sawyer::Resource>
```

The `endpoint` defines the intersection of the request URL. Each method described below defines a subsequent path. In the above example, `get 'users'` will request to `GET https://example.com/v1/users`.

Next, define `#initialize`. Suppose you want to set an Access Token, API Key, etc. as in the example above. You can omit the definition if you don't need it.

Then define `#get_users` and `#post_user`. It's a good idea to give the method name the title of the API. I'm calling `#get` and `#post` inside the method, which is the HTTP Method at the time of the request. You can also use `#patch` `#put` `#delete`.

### Pagination

Some APIs include a URL in the response to get the continuation of the result.

MyApiClient provides a method called `#pageable_get` to handle such APIs as enumerable. An example is shown below:

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

In the above example, the request is first made for `GET https://example.com/v1/pagination?page=1`, followed by the URL contained in the response JSON `$.link.next`. Make a request to enumerable.

For example, in the following response, `$.link.next` indicates `"https://example.com/pagination?page=3"`:

```json
{
  "links": {
    "next": "https://example.com/pagination?page=3",
    "previous": "https://example.com/pagination?page=1"
  },
  "page": 2
}
```

`#pageable_get` returns [Enumerator::Lazy](https://docs.ruby-lang.org/ja/latest/class/Enumerator=3a=3aLazy.html), so you can get the following result by `#each` or `#next`:

```ruby
api_clinet = MyPaginationApiClient.new
api_clinet.pagination.each do |response|
  # Do something.
end

result = api_clinet.pagination
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

MyApiClient allows you to define error handling that raises an exception depending on the content of the response. Here, as an example, error handling is defined in the above code:

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

  # @param params [MyApiClient::Params::Params] HTTP reqest and response params
  # @param logger [MyApiClient::Request::Logger] Logger for a request processing
  def my_error_handling(params, logger)
    logger.warn "Response Body: #{params.response.body.inspect}"
  end
end
```

I will explain one by one. First, about the one that specifies `status_code` as follows:

```ruby
error_handling status_code: 400..499, raise: MyApiClient::ClientError
```

This will cause `MyApiClient::ClientError` to occur as an exception if the status code of the response is `400..499` for all requests from `ExampleApiClient`. Error handling also applies to classes that inherit from `ExampleApiClient`.

Note that `Integer` `Range`, and `Regexp` can be specified for `status_code`.

A class that inherits `MyApiClient::Error` can be specified for `raise`. Please check [here](https://github.com/ryz310/my_api_client/blob/master/lib/my_api_client/errors) for the error class defined as standard in `my_api_client`. If `raise` is omitted, `MyApiClient::Error` will be raised.

Next, about the case of specifying `block`:

```ruby
error_handling status_code: 500..599, raise: MyApiClient::ServerError do |_params, logger|
  logger.warn 'Server error occurred.'
end
```

In the above example, if the status code is `500..599`, the contents of `block` will be executed before raising `MyApiClient::ServerError`. The argument `params` contains request and response information.

`logger` is an instance for log output. If you log output using this instance, the request information will be included in the log output as shown below, which is convenient for debugging:

```text
API request `GET https://example.com/path/to/resouce`: "Server error occurred."
```

```ruby
error_handling json: { '$.errors.code': 10..19 }, with: :my_error_handling
```

For `json`, specify [JSONPath](https://goessner.net/articles/JsonPath/) for the Key of `Hash`, get an arbitrary value from the response JSON, and check whether it matches value. You can handle errors. You can specify `String` `Integer` `Range` and `Regexp` for value.

In the above case, it matches JSON as below:

```json
{
  "erros": {
    "code": 10,
    "message": "Some error has occurred."
  }
}
```

For `headers`, specify response header for the Key of `Hash`, get an arbitrary value from the response header, and check whether it matches value. You can handle errors. You can specify `String` and `Regexp` for value.

```ruby
error_handling headers: { 'www-authenticate': /invalid token/ }, with: :my_error_handling
```

In the above case, it matches response header as below:

```text
cache-control: no-cache, no-store, max-age=0, must-revalidate
content-type: application/json
www-authenticate: Bearer error="invalid_token", error_description="invalid token"
content-length: 104
```

By specifying the instance method name in `with`, when an error is detected, any method can be executed before raising an exception. The arguments passed to the method are `params` and `logger` as in the `block` definition. Note that `block` and` with` cannot be used at the same time.

```ruby
# @param params [MyApiClient::Params::Params] HTTP req and res params
# @param logger [MyApiClient::Request::Logger] Logger for a request processing
def my_error_handling(params, logger)
  logger.warn "Response Body: #{params.response.body.inspect}"
end
```

#### Default error handling

In MyApiClient, the response of status code 400 ~ 500 series is handled as an exception by default. If the status code is in the 400s, an exception class that inherits `MyApiClient::ClientError` is raised, and in the 500s, an exception class that inherits `MyApiClient::ServerError` is raised.

Also, `retry_on` is defined by default for `MyApiClient::NetworkError`.

Both can be overridden, so define `error_handling` as needed.

They are defined [here](https://github.com/ryz310/my_api_client/blob/master/lib/my_api_client/default_error_handlers.rb).

#### Use Symbol

```ruby
error_handling json: { '$.errors.code': :negative? }
```

Although it is an experimental function, by specifying `Symbol` for value of `status` or `json`, you can call a method for the result value and judge the result. In the above case, it matches the following JSON. If `#negative?` does not exist in the target object, the method will not be called.

#### forbid_nil

```ruby
error_handling status_code: 200, json: :forbid_nil
```

It seems that some services expect an empty Response Body to be returned from the server, but an empty result is returned. This is also an experimental feature, but we have provided the `json: :forbid_nil` option to detect such cases. Normally, if the response body is empty, no error judgment is made, but if this option is specified, it will be detected as an error. Please be careful about false positives because some APIs have an empty normal response.

#### MyApiClient::Params::Params

WIP

#### MyApiClient::Error

If the response of the API request matches the matcher defined in `error_handling`, the exception handling specified in `raise` will occur. This exception class must inherit `MyApiClient::Error`.

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

If you are using [Bugsnag-Ruby v6.11.0](https://github.com/bugsnag/bugsnag-ruby/releases/tag/v6.11.0) or later, [breadcrumbs function](https://docs. bugsnag.com/platforms/ruby/other/#logging-breadcrumbs) is automatically supported. With this function, `Bugsnag.leave_breadcrumb` is called internally when `MyApiClient::Error` occurs, and you can check the request information, response information, etc. when an error occurs from the Bugsnag console.

### Retry

Next, I would like to introduce the retry function provided by MyApiClient.

```ruby
class ExampleApiClient < MyApiClient::Base
  endpoint 'https://example.com'

  retry_on MyApiClient::NetworkError, wait: 0.1.seconds, attempts: 3
  retry_on MyApiClient::ApiLimitError, wait: 30.seconds, attempts: 3

  error_handling json: { '$.errors.code': 20 }, raise: MyApiClient::ApiLimitError
end
```

If the API request is executed many times, a network error may occur due to a line malfunction. In some cases, the network will be unavailable for a long time, but in many cases it will be a momentary error. In MyApiClient, network exceptions are collectively raised as `MyApiClient::NetworkError`. The details of this exception will be described later, but by using `retry_on`, it is possible to supplement arbitrary exception handling like `ActiveJob` and retry the API request a certain number of times and after a certain period of time.

Note that `retry_on MyApiClient::NetworkError` is implemented as standard, so it will be applied automatically without any special definition. Please define and use it only when you want to set an arbitrary value for `wait` or `attempts`.

However, unlike `ActiveJob`, it retries in synchronous processing, so I think that there is not much opportunity to use it other than retrying in case of a momentary network interruption. As in the above example, there may be cases where you retry in preparation for API Rate Limit, but it may be better to handle this with `ActiveJob`.

By the way, `discard_on` is also implemented, but since the author himself has not found an effective use, I will omit the details. Please let me know if there is a good way to use it.

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

If you do not need to specify `wait` or` attempts` in `retry_on`, it works with `retry: true`:

```ruby
error_handling json: { '$.errors.code': 20 },
               raise: MyApiClient::ApiLimitError,
               retry: true
```

Keep the following in mind when using the `retry` option:

- The `raise` option must be specified for `error_handling`
- Definition of `error_handling` using `block` is prohibited

#### MyApiClient::NetworkError

As mentioned above, in MyApiClient, network exceptions are collectively `raised` as `MyApiClient::NetworkError`. Like the other exceptions, it has `MyApiClient::Error` as its parent class. A list of exception classes treated as `MyApiClient::NetworkError` can be found in `MyApiClient::NETWORK_ERRORS`. You can also refer to the original exception with `#original_error`:

```ruby
begin
  api_client.request
rescue MyApiClient::NetworkError => e
  e.original_error # => #<Net::OpenTimeout>
  e.params.response # => nil
end
```

Note that a normal exception is raised depending on the result of the request, but since this exception is raised during the request, the exception instance does not include the response parameter.

### Timeout

WIP

### Logger

WIP

## RSpec

### Setup

Supports testing with RSpec.
Add the following code to `spec/spec_helper.rb` (or `spec/rails_helper.rb`):

```ruby
require 'my_api_client/rspec'
```

### Testing

Suppose you have defined a `ApiClient` like this:

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

WIP

### Stubbing

WIP

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/my_api_client. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the MyApiClient project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/my_api_client/blob/master/CODE_OF_CONDUCT.md).
