# Change log

## v0.10.3 (Nov 22, 2019)

### Feature
### Bugfix
### Breaking Change
### Misc

* [#136](https://github.com/ryz310/my_api_client/pull/136) Re-generate .rubocop_todo.yml with RuboCop v0.76.0 ([@ryz310](https://github.com/ryz310))
* [#137](https://github.com/ryz310/my_api_client/pull/137) Configure Renovate ([@ryz310](https://github.com/ryz310))
* [#138](https://github.com/ryz310/my_api_client/pull/138) Update ruby-orbs orb to v1.4.4 ([@ryz310](https://github.com/ryz310))
* [#139](https://github.com/ryz310/my_api_client/pull/139) Bump rake from 13.0.0 to 13.0.1 ([@ryz310](https://github.com/ryz310))
* [#140](https://github.com/ryz310/my_api_client/pull/140) Bump rubocop-performance from 1.5.0 to 1.5.1 ([@ryz310](https://github.com/ryz310))
* [#141](https://github.com/ryz310/my_api_client/pull/141) Update ruby-orbs orb to v1.4.5 ([@ryz310](https://github.com/ryz310))

## 0.10.2 (Oct 23, 2019)

### Bugfix

* Ignore error handling when using request to matcher ([#130](https://github.com/ryz310/my_api_client/pull/130))
* Fix `be_handled_as_an_error` description ([#131](https://github.com/ryz310/my_api_client/pull/131))

## 0.10.1 (Oct 23, 2019)

### Feature

* Support `retry_on` testing at shoulda matcher ([#127](https://github.com/ryz310/my_api_client/pull/127))

## 0.10.0 (Oct 23, 2019)

### Feature

* Shoulda-matchers for my_api_client ([#124](https://github.com/ryz310/my_api_client/pull/124))

### Misc

* Modify request specifications ([#120](https://github.com/ryz310/my_api_client/pull/120))
* Re-generate .rubocop_todo.yml with RuboCop v0.75.1 ([#121](https://github.com/ryz310/my_api_client/pull/121))
* ryz310/dependabot/bundler/jsonpath-1.0.5 ([#123](https://github.com/ryz310/my_api_client/pull/123))

## 0.9.2 (Oct 8, 2019)

### Bugfix

* Fix endpoint parsing when including port number ([#117](https://github.com/ryz310/my_api_client/pull/117))
    * Fixes: Can't request to URL which includes port numbert ([#116](https://github.com/ryz310/my_api_client/pull/116))

### Misc

* Re-generate .rubocop_todo.yml with RuboCop v0.74.0 ([#100](https://github.com/ryz310/my_api_client/pull/100))
* Re-generate .rubocop_todo.yml with RuboCop v0.75.0 ([#112](https://github.com/ryz310/my_api_client/pull/112))
* Support Rails 6.0 ([#101](https://github.com/ryz310/my_api_client/pull/101))

* deprecated/my_api_client_stub ([#102](https://github.com/ryz310/my_api_client/pull/102))
* dependabot/bundler/rake-tw-13.0 ([#105](https://github.com/ryz310/my_api_client/pull/105))
* dependabot/bundler/webmock-3.7.5 ([#108](https://github.com/ryz310/my_api_client/pull/108))
* dependabot/bundler/bugsnag-6.12.1 ([#109](https://github.com/ryz310/my_api_client/pull/109))
* dependabot/bundler/simplecov-0.17.1 ([#110](https://github.com/ryz310/my_api_client/pull/110))
* dependabot/bundler/rubocop-rspec-1.36.0 ([#111](https://github.com/ryz310/my_api_client/pull/111))
* dependabot/bundler/rubocop-performance-1.5.0 ([#115](https://github.com/ryz310/my_api_client/pull/115))

## 0.9.1 (July 25, 2019)

### Bugfix

* Fix forbid nil option ([#97](https://github.com/ryz310/my_api_client/pull/97)) **Breaking Changes**

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
    * Fixes: The logger does not work... ([#54](https://github.com/ryz310/my_api_client/pull/54))

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
