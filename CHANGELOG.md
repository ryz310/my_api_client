# Change log

## 0.9.0 (July 25, 2019)

### New Features

* Forbid nil response ([#93](https://github.com/ryz310/my_api_client/pull/93))

### Misc

* RSpec/DescribedClass-20190723233015 ([#92](https://github.com/ryz310/my_api_client/pull/92))

## 0.8.0 (July 23, 2019)

### New Features

* Allow method calling on error handling ([#89](https://github.com/ryz310/my_api_client/pull/89))

### Breaking Changes

* Require sawyer gem v0.8.2 over ([#88](https://github.com/ryz310/my_api_client/pull/88))

## 0.7.0 (July 17, 2019)

### Features

* Add request duration to metadata ([#80](https://github.com/ryz310/my_api_client/pull/80))
* Support boolean on error handling ([#81](https://github.com/ryz310/my_api_client/pull/81))

### Breaking Changes

* Modify the generator to be simple ([#82](https://github.com/ryz310/my_api_client/pull/82))

### Misc

* Re-generate .rubocop_todo.yml with RuboCop v0.73.0 ([#79](https://github.com/ryz310/my_api_client/pull/79))
* Introduce gem comet ([#85](https://github.com/ryz310/my_api_client/pull/85))

## 0.6.2 (July 03, 2019)

### Bug fixes

* Fix logger setter on the template ([#76](https://github.com/ryz310/my_api_client/pull/76))
    * Fix #54

## 0.6.1 (July 03, 2019)

### Misc

* Bump yard from `0.9.19` to `0.9.20` ([#72](https://github.com/ryz310/my_api_client/pull/72))
    * Fix a security risk

## 0.6.0 (June 25, 2019)

### New Features

* New stubbing helper ([#65](https://github.com/ryz310/my_api_client/pull/65))

```rb
stub_api_client_all(
  ExampleApiClient,
  get_user: { response: { id: 1 } },               # Returns an arbitrary response.
  post_users: { id: 1 },                           # You can ommit `response` keyword.
  patch_user: ->(params) { { id: params[:id] } },  # Returns calculated result as response.
  delete_user: { raise: MyApiClient::ClientError } # Raises an arbitrary error.
)
response = ExampleApiClient.new.get_user(id: 123)
response.id # => 1
```

```rb
api_client = stub_api_client(
  ExampleApiClient,
  get_user: { response: { id: 1 } },               # Returns an arbitrary response.
  post_users: { id: 1 },                           # You can ommit `response` keyword.
  patch_user: ->(params) { { id: params[:id] } },  # Returns calculated result as response.
  delete_user: { raise: MyApiClient::ClientError } # Raises an arbitrary error.
)
response = api_client.get_user(id: 123)
response.id # => 1
```

## 0.5.3 (June 23, 2019)

### Bug Fixes

* Initialize sawyer agent before logger initialization ([#60](https://github.com/ryz310/my_api_client/pull/60))
    * Fixes: The URL included in the logger is incomplete ([#53](https://github.com/ryz310/my_api_client/pull/53))
* Fix parsing error if given text/html response ([#61](https://github.com/ryz310/my_api_client/pull/61))

## 0.5.2 (June 23, 2019)

### Bug Fixes

* Fix the result of the retry ([#57](https://github.com/ryz310/my_api_client/pull/57))
    * Issue: Return values are nil after retrying ([#56](https://github.com/ryz310/my_api_client/pull/56))

### Misc

* Improvement test coverage ([#55](https://github.com/ryz310/my_api_client/pull/55))

## 0.5.1 (June 19, 2019)

### Bug Fixes

* Fix unsupported data for the Bugsnag breadcrumbs ([#50](https://github.com/ryz310/my_api_client/pull/50))

## 0.5.0 (June 16, 2019)

### New Features

* Support bugsnag breadcrumb ([#41](https://github.com/ryz310/my_api_client/pull/41))

### Misc

* Use CircleCI Orbs ([#43](https://github.com/ryz310/my_api_client/pull/43))

## 0.4.0 (June 03, 2019)

### Feature

* Improvement for endpoint ([#35](https://github.com/ryz310/my_api_client/pull/35))

### Bug Fix

* Add requirements for `$ bin/console` ([#31](https://github.com/ryz310/my_api_client/pull/31))

### Misc

* Update RuboCop v0.70.0 -> v0.71.0 ([#34](https://github.com/ryz310/my_api_client/pull/34))

## 0.3.0 (May 29, 2019)

### New Features

* Provide test helper for RSpec ([#28](https://github.com/ryz310/my_api_client/pull/28))

## 0.2.0 (May 29, 2019)

### New Features

* Support Bugsnag metadata ([#22](https://github.com/ryz310/my_api_client/pull/22))

### Misc

* Improve test coverage ([#24](https://github.com/ryz310/my_api_client/pull/24))
* Fix problem on the release job ([#25](https://github.com/ryz310/my_api_client/pull/25))

## 0.1.4 (May 28, 2019)

### Bugfix

* Support activesupport before v5.2.0 ([#17](https://github.com/ryz310/my_api_client/pull/17))

## 0.1.3 (May 27, 2019)

* Fix wrong variable name ([#13](https://github.com/ryz310/my_api_client/pull/13))

## 0.1.2 (May 27, 2019)

* Fix wrong method name ([#10](https://github.com/ryz310/my_api_client/pull/10))

## 0.1.1 (May 27, 2019)

* Fix typo ([#6](https://github.com/ryz310/my_api_client/pull/6))

## 0.1.0 (May 27, 2019)

* The first release :tada:
