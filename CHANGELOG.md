# Change log

## v1.1.0 (Jan 09, 2024)

### Bugfix

- [#970](https://github.com/ryz310/my_api_client/pull/970) Fix handling when the error changes after a retry ([@ashimomura](https://github.com/ashimomura))

### Dependabot

- [#965](https://github.com/ryz310/my_api_client/pull/965) Bump faraday from 2.7.12 to 2.8.1 ([@ryz310](https://github.com/ryz310))
- [#972](https://github.com/ryz310/my_api_client/pull/972) Bump rubocop-performance from 1.19.1 to 1.20.2 ([@ryz310](https://github.com/ryz310))

## v1.0.0 (Dec 07, 2023)

### Feature

- [#955](https://github.com/ryz310/my_api_client/pull/955) Enable Dynamic URL Generation for `#pageable_get` via `Proc` Objects ([@ryz310](https://github.com/ryz310))

```ruby
# Example of using a Proc with pageable_get
pget 'api/example', headers:, query:, paging: ->(response) {
  # Custom logic to generate the next URL
}
```

### Dependabot

- [#950](https://github.com/ryz310/my_api_client/pull/950) Bump faraday from 2.7.11 to 2.7.12 ([@ryz310](https://github.com/ryz310))

## v0.27.0 (Nov 13, 2023)

### Feature

- [#944](https://github.com/ryz310/my_api_client/pull/944) Add block to retrieve sawyer response ([@okumud](https://github.com/okumud))

```rb
api_clinet = ExampleApiClient.new(access_token: 'access_token')

# You can retrieve sawyer response with return value
api_clinet.get_users #=> #<Sawyer::Resource>

# You can retrieve sawyer response with block
api_clinet.get_users do |response|
  response #=> #<Sawyer::Response>
  response.headers #=> #<Hash>
  response.data #=> #<Sawyer::Resource>
end
```

### Breaking Change

- [#931](https://github.com/ryz310/my_api_client/pull/931) End of support for ruby 2.7 and rails 6.0 ([@ryz310](https://github.com/ryz310))

### Dependabot

- [#919](https://github.com/ryz310/my_api_client/pull/919) Bump bugsnag from 6.25.2 to 6.26.0 ([@ryz310](https://github.com/ryz310))
- [#929](https://github.com/ryz310/my_api_client/pull/929) Bump webmock from 3.19.0 to 3.19.1 ([@ryz310](https://github.com/ryz310))
- [#934](https://github.com/ryz310/my_api_client/pull/934) Bump rubocop-performance from 1.19.0 to 1.19.1 ([@ryz310](https://github.com/ryz310))
- [#933](https://github.com/ryz310/my_api_client/pull/933) Bump faraday from 2.7.10 to 2.7.11 ([@ryz310](https://github.com/ryz310))
- [#939](https://github.com/ryz310/my_api_client/pull/939) Bump jsonpath from 1.1.4 to 1.1.5 ([@ryz310](https://github.com/ryz310))
- [#942](https://github.com/ryz310/my_api_client/pull/942) Bump rake from 13.0.6 to 13.1.0 ([@ryz310](https://github.com/ryz310))
- [#945](https://github.com/ryz310/my_api_client/pull/945) Bump activesupport from 7.1.1 to 7.1.2 ([@ryz310](https://github.com/ryz310))

### Misc

- [#946](https://github.com/ryz310/my_api_client/pull/946) Fix a broken spec ([@ryz310](https://github.com/ryz310))

## v0.26.0 (Jul 04, 2023)

### Bugfix

- [#914](https://github.com/ryz310/my_api_client/pull/914) Fix error that generating api client failed on Rails 7 ([@ryz310](https://github.com/ryz310))

### Dependabot

- [#889](https://github.com/ryz310/my_api_client/pull/889) Bump yard from 0.9.32 to 0.9.34 ([@ryz310](https://github.com/ryz310))
- [#893](https://github.com/ryz310/my_api_client/pull/893) Bump jsonpath from 1.1.2 to 1.1.3 ([@ryz310](https://github.com/ryz310))
- [#897](https://github.com/ryz310/my_api_client/pull/897) Bump rubocop-performance from 1.17.1 to 1.18.0 ([@ryz310](https://github.com/ryz310))
- [#912](https://github.com/ryz310/my_api_client/pull/912) Bump activesupport from 7.0.5.1 to 7.0.6 ([@ryz310](https://github.com/ryz310))
- [#913](https://github.com/ryz310/my_api_client/pull/913) Bump faraday from 2.7.8 to 2.7.9 ([@ryz310](https://github.com/ryz310))

## v0.25.0 (Feb 12, 2023)

### Breaking Change

- [#864](https://github.com/ryz310/my_api_client/pull/864) Support Ruby 3.2 and drop support for Rails 5.2 ([@ryz310](https://github.com/ryz310))

### Rubocop Challenge

- [#809](https://github.com/ryz310/my_api_client/pull/809) Style/RedundantConstantBase-20221208233100 ([@ryz310](https://github.com/ryz310))
- [#812](https://github.com/ryz310/my_api_client/pull/812) Lint/RedundantCopDisableDirective-20221211233112 ([@ryz310](https://github.com/ryz310))
- [#862](https://github.com/ryz310/my_api_client/pull/862) Performance/StringInclude-20230206233100 ([@ryz310](https://github.com/ryz310))

### Dependabot

- [#830](https://github.com/ryz310/my_api_client/pull/830) ryz310/dependabot/bundler/simplecov-0.22.0 ([@ryz310](https://github.com/ryz310))
- [#858](https://github.com/ryz310/my_api_client/pull/858) Bump faraday from 2.7.3 to 2.7.4 ([@ryz310](https://github.com/ryz310))
- [#859](https://github.com/ryz310/my_api_client/pull/859) Bump activesupport from 7.0.4.1 to 7.0.4.2 ([@ryz310](https://github.com/ryz310))
- [#863](https://github.com/ryz310/my_api_client/pull/863) Bump bugsnag from 6.25.1 to 6.25.2 ([@ryz310](https://github.com/ryz310))

## v0.24.0 (Nov 07, 2022)

### Feature

- [#792](https://github.com/ryz310/my_api_client/pull/792) Support response header error handling ([@okumud](https://github.com/okumud))

### Rubocop Challenge

- [#757](https://github.com/ryz310/my_api_client/pull/757) RSpec/Rails/HaveHttpStatus-20220712233101 ([@ryz310](https://github.com/ryz310))
- [#777](https://github.com/ryz310/my_api_client/pull/777) RSpec/ClassCheck-20220912233101 ([@ryz310](https://github.com/ryz310))
- [#790](https://github.com/ryz310/my_api_client/pull/790) RSpec/Rails/InferredSpecType-20221023233100 ([@ryz310](https://github.com/ryz310))

### Dependabot

- [#758](https://github.com/ryz310/my_api_client/pull/758) ryz310/dependabot/bundler/rubocop-performance-1.14.3 ([@ryz310](https://github.com/ryz310))
- [#772](https://github.com/ryz310/my_api_client/pull/772) Bump pry-byebug from 3.10.0 to 3.10.1 ([@ryz310](https://github.com/ryz310))
- [#773](https://github.com/ryz310/my_api_client/pull/773) Bump webmock from 3.17.1 to 3.18.1 ([@ryz310](https://github.com/ryz310))
- [#775](https://github.com/ryz310/my_api_client/pull/775) Bump activesupport from 7.0.3.1 to 7.0.4 ([@ryz310](https://github.com/ryz310))
- [#778](https://github.com/ryz310/my_api_client/pull/778) Bump rspec_junit_formatter from 0.5.1 to 0.6.0 ([@ryz310](https://github.com/ryz310))
- [#780](https://github.com/ryz310/my_api_client/pull/780) Bump faraday from 2.5.2 to 2.6.0 ([@ryz310](https://github.com/ryz310))
- [#791](https://github.com/ryz310/my_api_client/pull/791) Bump rspec from 3.11.0 to 3.12.0 ([@ryz310](https://github.com/ryz310))

### Misc

- [#784](https://github.com/ryz310/my_api_client/pull/784) Pin the version of the jets gem ([@ryz310](https://github.com/ryz310))

## v0.23.0 (Jun 08, 2022)

### Feature

- [#731](https://github.com/ryz310/my_api_client/pull/731) Allow the error class to be initialized with no arguments ([@ryz310](https://github.com/ryz310))

### Breaking Change

- [#711](https://github.com/ryz310/my_api_client/pull/711) Bump up ruby version ([@ryz310](https://github.com/ryz310))

### Rubocop Challenge

- [#698](https://github.com/ryz310/my_api_client/pull/698) RSpec/VerifiedDoubleReference-20220419233100 ([@ryz310](https://github.com/ryz310))
- [#700](https://github.com/ryz310/my_api_client/pull/700) Style/FetchEnvVar-20220421233101 ([@ryz310](https://github.com/ryz310))
- [#728](https://github.com/ryz310/my_api_client/pull/728) Re-generate .rubocop_todo.yml with RuboCop v1.30.1 ([@ryz310](https://github.com/ryz310))

### Dependabot

- [#658](https://github.com/ryz310/my_api_client/pull/658) ryz310/dependabot/bundler/rspec_junit_formatter-0.5.1 ([@ryz310](https://github.com/ryz310))
- [#666](https://github.com/ryz310/my_api_client/pull/666) Bump bugsnag from 6.24.1 to 6.24.2 ([@ryz310](https://github.com/ryz310))
- [#667](https://github.com/ryz310/my_api_client/pull/667) Bump rubocop-rspec from 2.7.0 to 2.8.0 ([@ryz310](https://github.com/ryz310))
- [#671](https://github.com/ryz310/my_api_client/pull/671) Bump rspec from 3.10.0 to 3.11.0 ([@ryz310](https://github.com/ryz310))
- [#678](https://github.com/ryz310/my_api_client/pull/678) Bump faraday from 1.10.0 to 2.2.0 ([@ryz310](https://github.com/ryz310))
- [#702](https://github.com/ryz310/my_api_client/pull/702) Bump jsonpath from 1.1.0 to 1.1.2 ([@ryz310](https://github.com/ryz310))
- [#715](https://github.com/ryz310/my_api_client/pull/715) Bump activesupport from 7.0.2.4 to 7.0.3 ([@ryz310](https://github.com/ryz310))
- [#726](https://github.com/ryz310/my_api_client/pull/726) Bump yard from 0.9.27 to 0.9.28 ([@ryz310](https://github.com/ryz310))
- [#729](https://github.com/ryz310/my_api_client/pull/729) Bump rubocop-performance from 1.14.1 to 1.14.2 ([@ryz310](https://github.com/ryz310))
- [#730](https://github.com/ryz310/my_api_client/pull/730) Bump sawyer from 0.9.1 to 0.9.2 ([@ryz310](https://github.com/ryz310))

## v0.22.0 (Dec 26, 2021)

### Feature

- [#648](https://github.com/ryz310/my_api_client/pull/648) Support Rails 7.0 ([@ryz310](https://github.com/ryz310))

### Rubocop Challenge

- [#617](https://github.com/ryz310/my_api_client/pull/617) RSpec/ExcessiveDocstringSpacing-20210922233114 ([@ryz310](https://github.com/ryz310))
- [#623](https://github.com/ryz310/my_api_client/pull/623) Security/IoMethods-20210930233112 ([@ryz310](https://github.com/ryz310))
- [#624](https://github.com/ryz310/my_api_client/pull/624) Re-generate .rubocop_todo.yml with RuboCop v1.22.1 ([@ryz310](https://github.com/ryz310))
- [#638](https://github.com/ryz310/my_api_client/pull/638) Gemspec/RequireMFA-20211115233105 ([@ryz310](https://github.com/ryz310))

### Dependabot

- [#576](https://github.com/ryz310/my_api_client/pull/576) Bump bugsnag from 6.21.0 to 6.22.1 ([@ryz310](https://github.com/ryz310))
- [#612](https://github.com/ryz310/my_api_client/pull/612) ryz310/dependabot/bundler/faraday-1.8.0 ([@ryz310](https://github.com/ryz310))
- [#625](https://github.com/ryz310/my_api_client/pull/625) ryz310/dependabot/bundler/bugsnag-6.24.0 ([@ryz310](https://github.com/ryz310))
- [#635](https://github.com/ryz310/my_api_client/pull/635) Bump rubocop-performance from 1.11.5 to 1.12.0 ([@ryz310](https://github.com/ryz310))
- [#636](https://github.com/ryz310/my_api_client/pull/636) ryz310/dependabot/bundler/rubocop-rspec-2.6.0 ([@ryz310](https://github.com/ryz310))
- [#639](https://github.com/ryz310/my_api_client/pull/639) Bump yard from 0.9.26 to 0.9.27 ([@ryz310](https://github.com/ryz310))
- [#640](https://github.com/ryz310/my_api_client/pull/640) Bump bugsnag from 6.24.0 to 6.24.1 ([@ryz310](https://github.com/ryz310))
- [#641](https://github.com/ryz310/my_api_client/pull/641) Bump activesupport from 6.1.4.1 to 6.1.4.2 ([@ryz310](https://github.com/ryz310))
- [#644](https://github.com/ryz310/my_api_client/pull/644) ryz310/dependabot/bundler/activesupport-6.1.4.4 ([@ryz310](https://github.com/ryz310))

## v0.21.0 (Aug 07, 2021)

### Feature

- [#570](https://github.com/ryz310/my_api_client/pull/570) Stubbing status code on testing ([@ryz310](https://github.com/ryz310))

### Breaking Change

- [#561](https://github.com/ryz310/my_api_client/pull/561) Goodbye Ruby 2.5.x! ([@ryz310](https://github.com/ryz310))

### Rubocop Challenge

- [#523](https://github.com/ryz310/my_api_client/pull/523) Layout/LineEndStringConcatenationIndentation-20210629233103 ([@ryz310](https://github.com/ryz310))
- [#562](https://github.com/ryz310/my_api_client/pull/562) Re-generate .rubocop_todo.yml with RuboCop v1.18.4 ([@ryz310](https://github.com/ryz310))

### Misc

- [#509](https://github.com/ryz310/my_api_client/pull/509) Fix the problem of mimemagic gem dependency ([@ryz310](https://github.com/ryz310))
- [#559](https://github.com/ryz310/my_api_client/pull/559) Fix gemfiles compatibility ([@ryz310](https://github.com/ryz310))

## v0.20.0 (Mar 07, 2021)

### Feature

- [#456](https://github.com/ryz310/my_api_client/pull/456) Stubbed pagination ([@ryz310](https://github.com/ryz310))

### Rubocop Challenge

- [#414](https://github.com/ryz310/my_api_client/pull/414) Style/StringConcatenation-20210106033935 ([@ryz310](https://github.com/ryz310))
- [#416](https://github.com/ryz310/my_api_client/pull/416) Style/HashTransformValues-20210106233116 ([@ryz310](https://github.com/ryz310))
- [#433](https://github.com/ryz310/my_api_client/pull/433) Lint/SymbolConversion-20210128233108 ([@ryz310](https://github.com/ryz310))
- [#452](https://github.com/ryz310/my_api_client/pull/452) Re-generate .rubocop_todo.yml with RuboCop v1.11.0 ([@ryz310](https://github.com/ryz310))

### Misc

- [#436](https://github.com/ryz310/my_api_client/pull/436) Use Circle CI matrix ([@ryz310](https://github.com/ryz310))

## v0.19.0 (Jan 04, 2021)

### Feature

- [#402](https://github.com/ryz310/my_api_client/pull/402) Support Ruby 3.0 and Rails 6.1 ([@ryz310](https://github.com/ryz310))

### Rubocop Challenge

- [#400](https://github.com/ryz310/my_api_client/pull/400) Re-generate .rubocop_todo.yml with RuboCop v1.7.0 ([@ryz310](https://github.com/ryz310))

## v0.18.0 (Dec 04, 2020)

### Feature

- [#381](https://github.com/ryz310/my_api_client/pull/381) Add endpoint option to the generator ([@ryz310](https://github.com/ryz310))

### Breaking Change

- [#365](https://github.com/ryz310/my_api_client/pull/365) End of support for Ruby 2.4 and Rails 4.2 ([@ryz310](https://github.com/ryz310))

### Rubocop Challenge

- [#383](https://github.com/ryz310/my_api_client/pull/383) Re-generate .rubocop_todo.yml with RuboCop v1.5.1 ([@ryz310](https://github.com/ryz310))

## v0.17.0 (Sep 20, 2020)

### Feature

- [#303](https://github.com/ryz310/my_api_client/pull/303) Change the duration format to milliseconds ([@ryz310](https://github.com/ryz310))
- [#308](https://github.com/ryz310/my_api_client/pull/308) Add testing for api client generators ([@ryz310](https://github.com/ryz310))

### Rubocop Challenge

- [#311](https://github.com/ryz310/my_api_client/pull/311) Style/GlobalStdStream-20200906233350 ([@ryz310](https://github.com/ryz310))
- [#312](https://github.com/ryz310/my_api_client/pull/312) Style/StringConcatenation-20200907233020 ([@ryz310](https://github.com/ryz310))
- [#313](https://github.com/ryz310/my_api_client/pull/313) Style/HashTransformValues-20200908233016 ([@ryz310](https://github.com/ryz310))
- [#316](https://github.com/ryz310/my_api_client/pull/316) Layout/EmptyLinesAroundAttributeAccessor-20200909233021 ([@ryz310](https://github.com/ryz310))
- [#320](https://github.com/ryz310/my_api_client/pull/320) Re-generate .rubocop_todo.yml with RuboCop v0.91.0 ([@ryz310](https://github.com/ryz310))

## v0.16.1 (Aug 27, 2020)

### Feature

- [#296](https://github.com/ryz310/my_api_client/pull/296) Support HTTP PUT method ([@ryz310](https://github.com/ryz310))

### Rubocop Challenge

- [#256](https://github.com/ryz310/my_api_client/pull/256) Performance/StartWith-20200523233027 ([@ryz310](https://github.com/ryz310))
- [#268](https://github.com/ryz310/my_api_client/pull/268) Lint/RedundantCopDisableDirective-20200622233019 ([@ryz310](https://github.com/ryz310))
- [#289](https://github.com/ryz310/my_api_client/pull/289) Re-generate .rubocop_todo.yml with RuboCop v0.89.1 ([@ryz310](https://github.com/ryz310))
- [#293](https://github.com/ryz310/my_api_client/pull/293) RSpec/LeadingSubject-20200817233022 ([@ryz310](https://github.com/ryz310))

### Misc

- [#271](https://github.com/ryz310/my_api_client/pull/271) Minor fixes ([@ryz310](https://github.com/ryz310))

## v0.16.0 (Mar 29, 2020)

### Breaking Change

#### [#225](https://github.com/ryz310/my_api_client/pull/225) Raise an exception whenever an error is detected ([@ryz310](https://github.com/ryz310))

Until now, using `with` or `block` in `error_handling` did not automatically raise an exception, but will now always raise an exception when an error is detected.
You can specify raising error class with `raise` option.

**Before**

```rb
error_handling json: { '$.errors.code': 10..19 }, with: :my_error_handling

def my_error_handling
  # Executes this method when an error is detected.
  # No exception is raised. You can raise an error if necessary.
end
```

```rb
error_handling status_code: 500..599 do |_params, logger|
  # Executes this block when an error is detected.
  # No exception is raised. You can raise an error if necessary.
end
```

**After**

```rb
error_handling json: { '$.errors.code': 10..19 }, with: :my_error_handling

def my_error_handling
  # Executes this method when an error is detected.
  # And then raise `MyApiClient::Error`.
end
```

```rb
error_handling status_code: 500..599 do |params, logger|
  # Executes this block when an error is detected.
  # And then raise `MyApiClient::Error`.
end
```

#### [#226](https://github.com/ryz310/my_api_client/pull/226) Default error handlers ([@ryz310](https://github.com/ryz310))

Until now, you needed define all `error_handling` or `retry_on` yourself. But will now some `error_handling` and `retry_on` are prepared as default.

You can check default `error_handling` or `retry_on` here.

See: https://github.com/ryz310/my_api_client/blob/master/lib/my_api_client/default_error_handlers.rb

### Misc

- [#229](https://github.com/ryz310/my_api_client/pull/229) Edit dependabot configuration ([@ryz310](https://github.com/ryz310))

## v0.15.0 (Mar 21, 2020)

### Feature

- [#220](https://github.com/ryz310/my_api_client/pull/220) Pageable HTTP request ([@ryz310](https://github.com/ryz310))

  - Add `#pageable_get` method (alias: `#pget`)
  - For example:

    - API client definition

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

    - The pagination API response
      ```json
      {
        "links": {
          "next": "https://example.com/pagination?page=3",
          "previous": "https://example.com/pagination?page=1"
        },
        "page": 2
      }
      ```
    - Usage

      ```ruby
      api_clinet = MyPaginationApiClient.new
      api_clinet.pagination.each do |response|
        # Do something.
      end

      p = api_clinet.pagination
      p.next # => 1st page result
      p.next # => 2nd page result
      p.next # => 3rd page result
      ```

- [#223](https://github.com/ryz310/my_api_client/pull/223) Use Enumerator::Lazy instead of Enumerator ([@ryz310](https://github.com/ryz310))

## v0.14.0 (Mar 14, 2020)

### Feature

- [#211](https://github.com/ryz310/my_api_client/pull/211) Integration testing using the jets framework ([@ryz310](https://github.com/ryz310))
- [#213](https://github.com/ryz310/my_api_client/pull/213) Add status API to integration testing ([@ryz310](https://github.com/ryz310))
- [#214](https://github.com/ryz310/my_api_client/pull/214) Add error API to integration testing ([@ryz310](https://github.com/ryz310))
- [#215](https://github.com/ryz310/my_api_client/pull/215) Update the REST API to enhance integration testing ([@ryz310](https://github.com/ryz310))

### Refactoring

- [#179](https://github.com/ryz310/my_api_client/pull/179) Change the "with" option structure ([@ryz310](https://github.com/ryz310))
- [#206](https://github.com/ryz310/my_api_client/pull/206) Rebuild api request processing ([@ryz310](https://github.com/ryz310))
- [#207](https://github.com/ryz310/my_api_client/pull/207) Fix offending codes ([@ryz310](https://github.com/ryz310))

### Breaking Change

- [#196](https://github.com/ryz310/my_api_client/pull/196) Change the request structure ([@ryz310](https://github.com/ryz310))

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

- [#205](https://github.com/ryz310/my_api_client/pull/205) Re-generate .rubocop_todo.yml with RuboCop v0.80.0 ([@ryz310](https://github.com/ryz310))
- [#210](https://github.com/ryz310/my_api_client/pull/210) Re-generate .rubocop_todo.yml with RuboCop v0.80.1 ([@ryz310](https://github.com/ryz310))

## v0.13.0 (Jan 21, 2020)

### Feature

- [#180](https://github.com/ryz310/my_api_client/pull/180) Stub response on raising error ([@ryz310](https://github.com/ryz310))

## v0.12.0 (Jan 19, 2020)

### Feature

- [#173](https://github.com/ryz310/my_api_client/pull/173) Avoid sleep on testing ([@ryz310](https://github.com/ryz310))
- [#175](https://github.com/ryz310/my_api_client/pull/175) Verify arguments on error handling definition ([@ryz310](https://github.com/ryz310))
- [#176](https://github.com/ryz310/my_api_client/pull/176) Provides a syntax sugar of `retry_on` on `error_handling` ([@ryz310](https://github.com/ryz310))

### Bugfix

- [#174](https://github.com/ryz310/my_api_client/pull/174) Fix warning on ruby 2.7 ([@ryz310](https://github.com/ryz310))

## v0.11.0 (Jan 16, 2020)

### Feature

- [#170](https://github.com/ryz310/my_api_client/pull/170) Support ruby 2.7 ([@ryz310](https://github.com/ryz310))

### Rubocop Challenge

- [#158](https://github.com/ryz310/my_api_client/pull/158) Re-generate .rubocop_todo.yml with RuboCop v0.78.0 ([@ryz310](https://github.com/ryz310))
- [#168](https://github.com/ryz310/my_api_client/pull/168) Re-generate .rubocop_todo.yml with RuboCop v0.79.0 ([@ryz310](https://github.com/ryz310))

## v0.10.3 (Dec 05, 2019)

### Bugfix

- [#150](https://github.com/ryz310/my_api_client/pull/150) Redefine network error class ([@ryz310](https://github.com/ryz310))

### Rubocop Challenge

- [#136](https://github.com/ryz310/my_api_client/pull/136) Re-generate .rubocop_todo.yml with RuboCop v0.76.0 ([@ryz310](https://github.com/ryz310))
- [#148](https://github.com/ryz310/my_api_client/pull/148) Re-generate .rubocop_todo.yml with RuboCop v0.77.0 ([@ryz310](https://github.com/ryz310))

## 0.10.2 (Oct 23, 2019)

### Bugfix

- Ignore error handling when using request to matcher ([#130](https://github.com/ryz310/my_api_client/pull/130))
- Fix `be_handled_as_an_error` description ([#131](https://github.com/ryz310/my_api_client/pull/131))

## 0.10.1 (Oct 23, 2019)

### Feature

- Support `retry_on` testing at shoulda matcher ([#127](https://github.com/ryz310/my_api_client/pull/127))

## 0.10.0 (Oct 23, 2019)

### Feature

- Shoulda-matchers for my_api_client ([#124](https://github.com/ryz310/my_api_client/pull/124))

### Misc

- Modify request specifications ([#120](https://github.com/ryz310/my_api_client/pull/120))
- Re-generate .rubocop_todo.yml with RuboCop v0.75.1 ([#121](https://github.com/ryz310/my_api_client/pull/121))

## 0.9.2 (Oct 8, 2019)

### Bugfix

- Fix endpoint parsing when including port number ([#117](https://github.com/ryz310/my_api_client/pull/117))
  - Fixes: Can't request to URL which includes port numbert ([#116](https://github.com/ryz310/my_api_client/pull/116))

### Misc

- Re-generate .rubocop_todo.yml with RuboCop v0.74.0 ([#100](https://github.com/ryz310/my_api_client/pull/100))
- Re-generate .rubocop_todo.yml with RuboCop v0.75.0 ([#112](https://github.com/ryz310/my_api_client/pull/112))
- Support Rails 6.0 ([#101](https://github.com/ryz310/my_api_client/pull/101))

- deprecated/my_api_client_stub ([#102](https://github.com/ryz310/my_api_client/pull/102))

## 0.9.1 (July 25, 2019)

### Bugfix

- Fix forbid nil option ([#97](https://github.com/ryz310/my_api_client/pull/97)) **Breaking Changes**

## 0.9.0 (July 25, 2019)

### New Features

- Forbid nil response ([#93](https://github.com/ryz310/my_api_client/pull/93))

### Misc

- RSpec/DescribedClass-20190723233015 ([#92](https://github.com/ryz310/my_api_client/pull/92))

## 0.8.0 (July 23, 2019)

### New Features

- Allow method calling on error handling ([#89](https://github.com/ryz310/my_api_client/pull/89))

### Breaking Changes

- Require sawyer gem v0.8.2 over ([#88](https://github.com/ryz310/my_api_client/pull/88))

## 0.7.0 (July 17, 2019)

### Features

- Add request duration to metadata ([#80](https://github.com/ryz310/my_api_client/pull/80))
- Support boolean on error handling ([#81](https://github.com/ryz310/my_api_client/pull/81))

### Breaking Changes

- Modify the generator to be simple ([#82](https://github.com/ryz310/my_api_client/pull/82))

### Misc

- Re-generate .rubocop_todo.yml with RuboCop v0.73.0 ([#79](https://github.com/ryz310/my_api_client/pull/79))
- Introduce gem comet ([#85](https://github.com/ryz310/my_api_client/pull/85))

## 0.6.2 (July 03, 2019)

### Bug fixes

- Fix logger setter on the template ([#76](https://github.com/ryz310/my_api_client/pull/76))
  - Fixes: The logger does not work... ([#54](https://github.com/ryz310/my_api_client/pull/54))

## 0.6.1 (July 03, 2019)

### Misc

- Bump yard from `0.9.19` to `0.9.20` ([#72](https://github.com/ryz310/my_api_client/pull/72))
  - Fix a security risk

## 0.6.0 (June 25, 2019)

### New Features

- New stubbing helper ([#65](https://github.com/ryz310/my_api_client/pull/65))

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

- Initialize sawyer agent before logger initialization ([#60](https://github.com/ryz310/my_api_client/pull/60))
  - Fixes: The URL included in the logger is incomplete ([#53](https://github.com/ryz310/my_api_client/pull/53))
- Fix parsing error if given text/html response ([#61](https://github.com/ryz310/my_api_client/pull/61))

## 0.5.2 (June 23, 2019)

### Bug Fixes

- Fix the result of the retry ([#57](https://github.com/ryz310/my_api_client/pull/57))
  - Issue: Return values are nil after retrying ([#56](https://github.com/ryz310/my_api_client/pull/56))

### Misc

- Improvement test coverage ([#55](https://github.com/ryz310/my_api_client/pull/55))

## 0.5.1 (June 19, 2019)

### Bug Fixes

- Fix unsupported data for the Bugsnag breadcrumbs ([#50](https://github.com/ryz310/my_api_client/pull/50))

## 0.5.0 (June 16, 2019)

### New Features

- Support bugsnag breadcrumb ([#41](https://github.com/ryz310/my_api_client/pull/41))

### Misc

- Use CircleCI Orbs ([#43](https://github.com/ryz310/my_api_client/pull/43))

## 0.4.0 (June 03, 2019)

### Feature

- Improvement for endpoint ([#35](https://github.com/ryz310/my_api_client/pull/35))

### Bug Fix

- Add requirements for `$ bin/console` ([#31](https://github.com/ryz310/my_api_client/pull/31))

### Misc

- Update RuboCop v0.70.0 -> v0.71.0 ([#34](https://github.com/ryz310/my_api_client/pull/34))

## 0.3.0 (May 29, 2019)

### New Features

- Provide test helper for RSpec ([#28](https://github.com/ryz310/my_api_client/pull/28))

## 0.2.0 (May 29, 2019)

### New Features

- Support Bugsnag metadata ([#22](https://github.com/ryz310/my_api_client/pull/22))

### Misc

- Improve test coverage ([#24](https://github.com/ryz310/my_api_client/pull/24))
- Fix problem on the release job ([#25](https://github.com/ryz310/my_api_client/pull/25))

## 0.1.4 (May 28, 2019)

### Bugfix

- Support activesupport before v5.2.0 ([#17](https://github.com/ryz310/my_api_client/pull/17))

## 0.1.3 (May 27, 2019)

- Fix wrong variable name ([#13](https://github.com/ryz310/my_api_client/pull/13))

## 0.1.2 (May 27, 2019)

- Fix wrong method name ([#10](https://github.com/ryz310/my_api_client/pull/10))

## 0.1.1 (May 27, 2019)

- Fix typo ([#6](https://github.com/ryz310/my_api_client/pull/6))

## 0.1.0 (May 27, 2019)

- The first release :tada:
