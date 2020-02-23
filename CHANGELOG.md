# Change log

## v0.14.0.pre (Feb 23, 2020)

### Refactoring

* [#179](https://github.com/ryz310/my_api_client/pull/179) Change the "with" option structure ([@ryz310](https://github.com/ryz310))
* [#206](https://github.com/ryz310/my_api_client/pull/206) Rebuild api request processing ([@ryz310](https://github.com/ryz310))
* [#207](https://github.com/ryz310/my_api_client/pull/207) Fix offending codes ([@ryz310](https://github.com/ryz310))

### Breaking Change

* [#196](https://github.com/ryz310/my_api_client/pull/196) Change the request structure ([@ryz310](https://github.com/ryz310))

> ### logging
>
> **before**
>
> ```
> I, [2020-02-02T15:26:53.788092 #93220]  INFO -- : API request `GET https://api.esa.io/v1/teams/feedforce/posts`: "Start"
> I, [2020-02-02T15:26:55.760452 #93220]  INFO -- : API request `GET https://api.esa.io/v1/teams/feedforce/posts`: "Duration 1.97186 sec"
> I, [2020-02-02T15:26:55.760739 #93220]  INFO -- : API request `GET https://api.esa.io/v1/teams/feedforce/posts`: "Success (200)"
> ```
>
> **after**
>
> Shows URL with query strings.
>
> ```
> I, [2020-02-02T15:20:47.471040 #90870]  INFO -- : API request `GET https://api.esa.io/v1/teams/feedforce/posts?page=1&per_page=100&q=user%3Aryosuke_sato+category%3Aunsorted`: "Start"
> I, [2020-02-02T15:20:49.516099 #90870]  INFO -- : API request `GET https://api.esa.io/v1/teams/feedforce/posts?page=1&per_page=100&q=user%3Aryosuke_sato+category%3Aunsorted`: "Duration 2.034907 sec"
> I, [2020-02-02T15:20:49.516391 #90870]  INFO -- : API request `GET https://api.esa.io/v1/teams/feedforce/posts?page=1&per_page=100&q=user%3Aryosuke_sato+category%3Aunsorted`: "Success (200)"
> ```
>
> ### MyApiClient::Params::Request
>
> **before**
>
> ```rb
> request_params.metadata # =>
> # {
> #   line: 'GET path/to/resource',
> #   headers: { 'Content-Type': 'application/json; charset=utf-8' },
> #   query: { key: 'value' }
> # }
> ```
>
> **after**
>
> The `#metadata` does not include `query` key and then includes full URL into `line` value.
>
> ```rb
> request_params.metadata # =>
> # {
> #   line: 'GET https://example.com/path/to/resource?key=value',
> #   headers: { 'Content-Type': 'application/json; charset=utf-8' }
> # }
> ```

### Rubocop Challenge

* [#205](https://github.com/ryz310/my_api_client/pull/205) Re-generate .rubocop_todo.yml with RuboCop v0.80.0 ([@ryz310](https://github.com/ryz310))

### Dependabot

* [#190](https://github.com/ryz310/my_api_client/pull/190) Add a config file of the dependabot ([@ryz310](https://github.com/ryz310))
* [#183](https://github.com/ryz310/my_api_client/pull/183) Bump pry-byebug from 3.7.0 to 3.8.0 ([@ryz310](https://github.com/ryz310))
* [#194](https://github.com/ryz310/my_api_client/pull/194) Bump bugsnag from 6.12.2 to 6.13.0 ([@ryz310](https://github.com/ryz310))
* [#197](https://github.com/ryz310/my_api_client/pull/197) Bump webmock from 3.8.0 to 3.8.1 ([@ryz310](https://github.com/ryz310))
* [#199](https://github.com/ryz310/my_api_client/pull/199) Bump webmock from 3.8.1 to 3.8.2 ([@ryz310](https://github.com/ryz310))

### Renovate

* [#193](https://github.com/ryz310/my_api_client/pull/193) Change renovate automerge setting ([@ryz310](https://github.com/ryz310))
* [#189](https://github.com/ryz310/my_api_client/pull/189) Update the renovate settings ([@ryz310](https://github.com/ryz310))
* [#184](https://github.com/ryz310/my_api_client/pull/184) Update ruby-orbs orb to v1.5.1 ([@ryz310](https://github.com/ryz310))
* [#185](https://github.com/ryz310/my_api_client/pull/185) Update ruby-orbs orb to v1.5.4 ([@ryz310](https://github.com/ryz310))
* [#187](https://github.com/ryz310/my_api_client/pull/187) Update ruby-orbs orb to v1.5.6 ([@ryz310](https://github.com/ryz310))
* [#192](https://github.com/ryz310/my_api_client/pull/192) Update ruby-orbs orb to v1.6.0 ([@ryz310](https://github.com/ryz310))

## v0.13.0 (Jan 21, 2020)

### Feature

* [#180](https://github.com/ryz310/my_api_client/pull/180) Stub response on raising error ([@ryz310](https://github.com/ryz310))

## v0.12.0 (Jan 19, 2020)

### Feature

* [#173](https://github.com/ryz310/my_api_client/pull/173) Avoid sleep on testing ([@ryz310](https://github.com/ryz310))
* [#175](https://github.com/ryz310/my_api_client/pull/175) Verify arguments on error handling definition ([@ryz310](https://github.com/ryz310))
* [#176](https://github.com/ryz310/my_api_client/pull/176) Provides a syntax sugar of `retry_on` on `error_handling` ([@ryz310](https://github.com/ryz310))

### Bugfix

* [#174](https://github.com/ryz310/my_api_client/pull/174) Fix warning on ruby 2.7 ([@ryz310](https://github.com/ryz310))

## v0.11.0 (Jan 16, 2020)

### Feature

* [#170](https://github.com/ryz310/my_api_client/pull/170) Support ruby 2.7 ([@ryz310](https://github.com/ryz310))

### Rubocop Challenge

* [#158](https://github.com/ryz310/my_api_client/pull/158) Re-generate .rubocop_todo.yml with RuboCop v0.78.0 ([@ryz310](https://github.com/ryz310))
* [#168](https://github.com/ryz310/my_api_client/pull/168) Re-generate .rubocop_todo.yml with RuboCop v0.79.0 ([@ryz310](https://github.com/ryz310))

### Dependabot

* [#156](https://github.com/ryz310/my_api_client/pull/156) Bump rubocop-rspec from 1.37.0 to 1.37.1 ([@ryz310](https://github.com/ryz310))
* [#159](https://github.com/ryz310/my_api_client/pull/159) Bump rubocop-performance from 1.5.1 to 1.5.2 ([@ryz310](https://github.com/ryz310))

## v0.10.3 (Dec 05, 2019)

### Bugfix

* [#150](https://github.com/ryz310/my_api_client/pull/150) Redefine network error class ([@ryz310](https://github.com/ryz310))

### Rubocop Challenge

* [#136](https://github.com/ryz310/my_api_client/pull/136) Re-generate .rubocop_todo.yml with RuboCop v0.76.0 ([@ryz310](https://github.com/ryz310))
* [#148](https://github.com/ryz310/my_api_client/pull/148) Re-generate .rubocop_todo.yml with RuboCop v0.77.0 ([@ryz310](https://github.com/ryz310))

### Dependabot

* [#139](https://github.com/ryz310/my_api_client/pull/139) Bump rake from 13.0.0 to 13.0.1 ([@ryz310](https://github.com/ryz310))
* [#140](https://github.com/ryz310/my_api_client/pull/140) Bump rubocop-performance from 1.5.0 to 1.5.1 ([@ryz310](https://github.com/ryz310))
* [#146](https://github.com/ryz310/my_api_client/pull/146) Bump rubocop-rspec from 1.36.0 to 1.37.0 ([@ryz310](https://github.com/ryz310))

### Renovate

* [#137](https://github.com/ryz310/my_api_client/pull/137) Configure Renovate ([@ryz310](https://github.com/ryz310))
* [#138](https://github.com/ryz310/my_api_client/pull/138) Update ruby-orbs orb to v1.4.4 ([@ryz310](https://github.com/ryz310))
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
