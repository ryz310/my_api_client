[![CircleCI](https://circleci.com/gh/ryz310/my_api_client.svg?style=svg)](https://circleci.com/gh/ryz310/my_api_client) [![Gem Version](https://badge.fury.io/rb/my_api_client.svg)](https://badge.fury.io/rb/my_api_client) [![Maintainability](https://api.codeclimate.com/v1/badges/861a2c8f168bbe995107/maintainability)](https://codeclimate.com/github/ryz310/my_api_client/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/861a2c8f168bbe995107/test_coverage)](https://codeclimate.com/github/ryz310/my_api_client/test_coverage) [![Dependabot Status](https://api.dependabot.com/badges/status?host=github&repo=ryz310/my_api_client)](https://dependabot.com)

# MyApiClient

MyApiClient は API リクエストクラスを作成するための汎用的な機能を提供します。Sawyer や Faraday をベースにエラーハンドリングの機能を強化した構造になっています。

ただし、 Sawyer はダミーデータの作成が難しかったり、他の gem で競合することがよくあるので、将来的には依存しないように変更していくかもしれません。

また、 Ruby on Rails で利用することを想定してますが、それ以外の環境でも動作するように作っています。不具合などあれば Issue ページからご報告下さい。

[toc]

## Supported Versions

* Ruby 2.5, 2.6, 2.7
* Rails 5.0, 5.1, 5.2, 6.0

## Installation

この gem は macOS と Linux で作動します。まずは `my_api_client` を Gemfile に追加します:

```ruby
gem 'my_api_client'
```

Ruby on Rails を利用している場合は `generator` 機能を利用できます。

```sh
$ rails g api_client path/to/resource get:path/to/resource --endpoint https://example.com

create  app/api_clients/application_api_client.rb
create  app/api_clients/path/to/resource_api_client.rb
invoke  rspec
create    spec/api_clients/path/to/resource_api_client_spec.rb
```

## Usage

### Basic

最もシンプルな利用例を以下に示します。

```ruby
class ExampleApiClient < MyApiClient::Base
  endpoint 'https://example.com/v1'

  attr_reader :access_token

  def initialize(access_token:)
    @access_token = access_token
  end

  # GET https://example.com/v1/users
  #
  # @return [Sawyer::Response] HTTP response parameter
  def get_users
    get 'users', headers: headers, query: { key: 'value' }
  end

  # POST https://example.com/v1/users
  #
  # @param name [String] Username which want to create
  # @return [Sawyer::Response] HTTP response parameter
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
api_clinet.get_users #=> #<Sawyer::Response>
```

クラス定義の最初に記述される `endpoint` にはリクエスト URL の共通部分を定義します。後述の各メソッドで後続の path を定義しますが、上記の例だと `get 'users'` と定義すると、 `GET https://example.com/v1/users` というリクエストが実行されます。

次に、 `#initialize` を定義します。上記の例のように Access Token や API Key などを設定することを想定します。必要なければ定義の省略も可能です。

続いて、 `#get_users` や `#post_user` を定義します。メソッド名には API のタイトルを付けると良いと思います。メソッド内部で `#get` や `#post` を呼び出していますが、これがリクエスト時の HTTP Method になります。他にも `#patch` `#put` `#delete` が利用可能です。

### Pagination

API の中にはレスポンスに結果の続きを取得するための URL を含んでいるものがあります。

MyApiClient では、このような API を enumerable に扱うための `#pageable_get` というメソッドを用意しています。以下に例を示します。

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

上記の例の場合、最初に `GET https://example.com/v1/pagination?page=1` に対してリクエストが実行され、続けてレスポンス JSON の `$.link.next` に含まれる URL に対して enumerable にリクエストを実行します。

例えば以下のようなレスポンスであれば、`$.link.next` は `"https://example.com/pagination?page=3"` を示します。

```json
{
  "links": {
    "next": "https://example.com/pagination?page=3",
    "previous": "https://example.com/pagination?page=1",
  },
  "page": 2
}
```

そして `#pageable_get` は [Enumerator::Lazy](https://docs.ruby-lang.org/ja/latest/class/Enumerator=3a=3aLazy.html) を返すので、 `#each` や `#next` を実行することで次の結果を取得できます。

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

なお、`#each` はレスポンスに含まれる `paging` の値が nil になるまで繰り返されるのでご注意ください。例えば `#take` と組み合わせることでページネーションの上限を設定できます。

`#pageable_get` の alias として `#pget` も利用可能です。

```ruby
# GET pagination?page=1
def pagination
  pget 'pagination', paging: '$.links.next', headers: headers, query: { page: 1 }
end
```

### Error handling

`my_api_client` ではレスポンスの内容によって例外を発生させるエラーハンドリングを定義できます。ここでは例として前述のコードにエラーハンドリングを定義しています。

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

  # Omission...

  private

  # @param params [MyApiClient::Params::Params] HTTP reqest and response params
  # @param logger [MyApiClient::Request::Logger] Logger for a request processing
  def my_error_handling(params, logger)
    logger.warn "Response Body: #{params.response.body.inspect}"
  end
end
```

一つずつ解説していきます。まず、以下のように `status_code` を指定するものについて。

```ruby
error_handling status_code: 400..499, raise: MyApiClient::ClientError
```

これは `ExampleApiClient` からのリクエスト全てにおいて、レスポンスのステータスコードが `400..499` であった場合に `MyApiClient::ClientError` が例外として発生するようになります。 `ExampleApiClient` を継承したクラスにもエラーハンドリングは適用されます。ステータスコードのエラーハンドリングは親クラスで定義すると良いと思います。

なお、 `status_code` には `Integer` `Range` `Regexp` が指定可能です。

`raise` には `MyApiClient::Error` を継承したクラスが指定可能です。`my_api_client` で標準で定義しているエラークラスについては以下のソースコードをご確認下さい。 `raise` を省略した場合は `MyApiClient::Error` を発生するようになります。

https://github.com/ryz310/my_api_client/blob/master/lib/my_api_client/errors

次に、 `block` を指定する場合について。

```ruby
error_handling status_code: 500..599, raise: MyApiClient::ServerError do |_params, logger|
  logger.warn 'Server error occurred.'
end
```

上記の例であれば、ステータスコードが `500..599` の場合に `MyApiClient::ServerError`  を発生させる前に `block` の内容が実行れます。引数の `params` にはリクエスト情報とレスポンス情報が含まれています。`logger` はログ出力用インスタンスですが、このインスタンスを使ってログ出力すると、以下のようにリクエスト情報がログ出力に含まれるようになり、デバッグの際に便利です。

```text
API request `GET https://example.com/path/to/resouce`: "Server error occurred."
```

```ruby
error_handling json: { '$.errors.code': 10..19 }, with: :my_error_handling
```

`json` には `Hash` の Key に [JSONPath](https://goessner.net/articles/JsonPath/) を指定して、レスポンス JSON から任意の値を取得し、 Value とマッチするかどうかでエラーハンドリングできます。Value には `String` `Integer` `Range` `Regexp` が指定可能です。上記の場合であれば、以下のような JSON にマッチします。

```json
{
    "erros": {
        "code": 10,
        "message": "Some error has occurred."
    }
}
```

`with` にはインスタンスメソッド名を指定することで、エラーを検出した際、例外を発生させる前に任意のメソッドを実行させることができます。メソッドに渡される引数は `block` 定義の場合と同じく `params` と `logger` です。なお、 `block` と `with` は同時には利用できません。

```ruby
# @param params [MyApiClient::Params::Params] HTTP req and res params
# @param logger [MyApiClient::Request::Logger] Logger for a request processing
def my_error_handling(params, logger)
  logger.warn "Response Body: #{params.response.body.inspect}"
end
```

#### Default error handling

`my_api_client` では、標準でステータスコード 400 ~ 500 番台のレスポンスを例外として処理するようにしています。ステータスコードが 400 番台場合は `MyApiClient::ClientError`、 500 番台の場合は `MyApiClient::ServerError` を継承した例外クラスが raise されます。

また、 `MyApiClient::NetworkError` に対しても標準で `retry_on` が定義されています。

いずれも override 可能ですので、必要に応じて `error_handling` を定義して下さい。

以下のファイルで定義しています。

https://github.com/ryz310/my_api_client/blob/master/lib/my_api_client/default_error_handlers.rb

#### Symbol を利用する

```ruby
error_handling json: { '$.errors.code': :negative? }
```

実験的な機能ですが、`status` や `json` の Value に `Symbol` を指定することで、結果値に対してメソッド呼び出しを行い、結果を判定させる事ができます。上記の場合、以下のような JSON にマッチします。なお、対象 Object に `#negative?` が存在しない場合はメソッドは呼び出されません。

```json
{
    "erros": {
        "code": -1,
        "message": "Some error has occurred."
    }
}
```

#### forbid_nil

```ruby
error_handling status_code: 200, json: :forbid_nil
```

一部のサービスではサーバーから何らかの Response Body が返ってくる事を期待しているにも関わらず、空の結果が結果が返ってくるというケースがあるようです。こちらも実験的な機能ですが、そういったケースを検出するために `json: :forbid_nil` オプションを用意しました。通常の場合、Response Body が空の場合はエラー判定をしませんが、このオプションを指定するとエラーとして検知する様になります。正常応答が空となる API も存在するので、誤検知にご注意下さい。

#### MyApiClient::Params::Params

WIP

#### MyApiClient::Error

API リクエストのレスポンスが `error_handling` で定義した matcher に合致した場合、 `raise` で指定した例外処理が発生します。この例外クラスは `MyApiClient::Error` を継承している必要があります。

この例外クラスには `#params` というメソッドが存在し、リクエストやレスポンスのパラメータを参照することが出来ます。

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

[Bugsnag-Ruby v6.11.0](https://github.com/bugsnag/bugsnag-ruby/releases/tag/v6.11.0) 以降を利用している場合は [breadcrumbs 機能](https://docs.bugsnag.com/platforms/ruby/other/#logging-breadcrumbs) が自動的にサポートされます。この機能によって `MyApiClient::Error` 発生時に内部で `Bugsnag.leave_breadcrumb` が呼び出され、 Bugsnag のコンソールからエラー発生時のリクエスト情報、レスポンス情報などが確認できるようになります。

### Retry

次に `MyApiClient` が提供するリトライ機能についてご紹介致します。

```ruby
class ExampleApiClient < MyApiClient::Base
  endpoint 'https://example.com'

  retry_on MyApiClient::NetworkError, wait: 0.1.seconds, attempts: 3
  retry_on MyApiClient::ApiLimitError, wait: 30.seconds, attempts: 3

  error_handling json: { '$.errors.code': 20 }, raise: MyApiClient::ApiLimitError
end
```

API リクエストを何度も実行していると回線の不調などによりネットワークエラーが発生する事があります。長時間ネットワークが使えなくなるケースもありますが、瞬間的なエラーであるケースも多々あります。 `MyApiClient` ではネットワーク系の例外はまとめて `MyApiClient::NetworkError` として `raise` されます。この例外の詳細は後述しますが、 `retry_on` を利用する事で、 `ActiveJob` のように任意の例外処理を補足して、一定回数、一定の期間を空けて API リクエストをリトライさせる事ができます。

なお、 `retry_on MyApiClient::NetworkError` は標準実装されているため、特別に定義せずとも自動的に適用されます。 `wait` や `attempts` に任意の値を設定したい場合のみ定義してご利用ください。

ただし、 `ActiveJob` とは異なり同期処理でリトライするため、ネットワークの瞬断に備えたリトライ以外ではあまり使う機会はないのではないかと思います。上記の例のように API Rate Limit に備えてリトライするケースもあるかと思いますが、こちらは `ActiveJob` で対応した方が良いかもしれません。

ちなみに一応 `discard_on` も実装していますが、作者自身が有効な用途を見出せていないので、詳細は割愛します。良い利用方法があれば教えてください。

#### 便利な使い方

`error_handling` に `retry` オプションを付与する事で `retry_on` の定義を省略できます。
例えば以下の 2 つのコードは同じ意味になります。

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

`retry_on` で `wait` や `attempts` を指定する必要がない場合は `retry: true` という記述で動作します。

```ruby
error_handling json: { '$.errors.code': 20 },
               raise: MyApiClient::ApiLimitError,
               retry: true
```

`retry` オプションを使用する際は以下の点に注意が必要です。

* `error_handling` に `raise` オプションの指定が必須となります。
* Block を使った `error_handling` の定義は禁止されます。

#### MyApiClient::NetworkError

前述の通りですが、 `MyApiClient` ではネットワーク系の例外はまとめて `MyApiClient::NetworkError` として `raise` されます。他の例外と同じく `MyApiClient::Error` を親クラスとしています。 `MyApiClient::NetworkError` として扱われる例外クラスの一覧は `MyApiClient::NETWORK_ERRORS` で参照できます。また、元となった例外は `#original_error` で参照できます。

```ruby
begin
  api_client.request
rescue MyApiClient::NetworkError => e
  e.original_error # => #<Net::OpenTimeout>
  e.params.response # => nil
end
```

なお、通常の例外はリクエストの結果によって発生しますが、この例外はリクエスト中に発生するため、例外インスタンスにレスポンスパラメータは含まれません。

### Timeout

WIP

### Logger

WIP

## One request for one class

多くの場合、同一ホストの API は リクエストヘッダーやエラー情報が同じ構造になっているため、上記のように一つのクラス内に複数の API を定義する設計が理にかなっていますが、 API 毎に個別に定義したい場合は、以下のように 1 つのクラスに 1 の API という構造で設計することも可能です。

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
  # @return [Sawyer::Response] HTTP response parameter
  def request
    get 'users', query: { key: 'value' }, headers: headers
  end
end

class PostUserApiClient < ExampleApiClient
  error_handling json: { '$.errors.code': 10 }, raise: MyApiClient::ApiLimitError

  # POST https://example.com/users
  #
  # @param name [String] Username which want to create
  # @return [Sawyer::Response] HTTP response parameter
  def request(name:)
    post 'users', headers: headers, body: { name: name }
  end
end
```

## RSpec

### Setup

RSpec を使ったテストをサポートしています。
以下のコードを `spec/spec_helper.rb` (または `spec/rails_helper.rb`) に追記して下さい。

```ruby
require 'my_api_client/rspec'
```

### Testing

以下のような `ApiClient` を定義しているとします。

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

通常の場合 `ApiClient` を新たに定義した際にテストすべき項目が 2 つあります。

1. 指定したエンドポイントに対して、任意のパラメータを使ったリクエストが実行されること
2. 特定のレスポンスに対して適切にエラーハンドリングが実行されること

`my_api_client` ではこれらをテストするための Custom Matcher を用意しています。

#### 1. 指定したエンドポイントに対して、任意のパラメータを使ったリクエストが実行されること

例えば上述の `#get_users` の内部では、入力引数を用いて検索クエリが組み立てられていたり、 Header に `access_token` を利用したりしています。これらの値が正しくリクエストに用いられているかどうかのテストが必要となります。

この場合 `request_to` と `with` という Custom Matcher を利用することで簡単にテストを記述することが出来ます。 `expect` にはブロック `{}` を指定する必要がある点にご注意ください。他にも `with` には `body` というキーワード引数も指定できます。

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
        .with(headers: headers, query: { condition: 'condition' })
    end
  end
end
```

#### 2. 特定のレスポンスに対して適切にエラーハンドリングが実行されること

次に `error_handling` についてのテストも記述していきます。ここではレスポンスのステータスコードが `200` かつ Body に `'$.errors.code': 10` という値が含まれていた場合は `MyApiClient::ClientError` を `raise` する、というエラーハンドリングが定義されています。

ここでは `be_handled_as_an_error` と `when_receive` という Custom Matcher を利用します。ここでも `expect` にはブロック `{}` を指定する必要がある点にご注意ください。

`be_handled_as_an_error` の引数には期待する例外クラスを指定します。 `when_receive` にはリクエスト結果としてどのような値が返ってきたのかを指定します。

なお、 `error_handling` で例外を発生させないケースは現在想定していないため、これ以外の Custom Matcher は定義されていません。何かユースケースがあれば教えて下さい。

```ruby
it do
  expect { api_client.get_users(condition: 'condition') }
    .to be_handled_as_an_error(MyApiClient::ClientError)
    .when_receive(status_code: 200, body: { errors: { code: 10 } }.to_json)
end
```

また、以下のように正常なレスポンスが返ってきた時に誤ってエラーハンドリングされていないかをテストすることもできます。

```ruby
it do
  expect { api_client.get_users(condition: 'condition') }
    .not_to be_handled_as_an_error(MyApiClient::ClientError)
    .when_receive(status_code: 200, body: { users: { id: 1 } }.to_json)
end
```

##### `retry_on` を定義している場合

以下のように `retry_on` を API Client に定義している場合:

```ruby
class ExampleApiClient < MyApiClient::Base
  endpoint 'https://example.com'

  error_handling json: { '$.errors.code': 20 }, raise: MyApiClient::ApiLimitError
  retry_on MyApiClient::ApiLimitError, wait: 30.seconds, attempts: 3
end
```

`after_retry` と `times` という Custom Matcher を利用することが出来ます。

```ruby
it do
  expect { api_client.get_users(condition: 'condition') }
    .to be_handled_as_an_error(MyApiClient::ApiLimitError)
    .after_retry(3).times
    .when_receive(status_code: 200, body: { errors: { code: 20 } }.to_json)
end
```

### Stubbing

以下のような `ApiClient` を定義しているとします。

```ruby
class ExampleApiClient < MyApiClient::Base
  endpoint 'https://example.com'

  def request(user_id:)
    get "users/#{user_id}"
  end
end
```

`stub_api_client_all` や `stub_api_client` を使うことで、 `ExampleApiClient#request` をスタブ化することができます。これで `#request` を実行してもリアルな HTTP リクエストが実行されなくなります。

```ruby
stub_api_client_all(
  ExampleApiClient,
  request: { response: { id: 12345 } }
)

response = ExampleApiClient.new.request(user_id: 1)
response.id # => 12345
```

`response` は省略することも可能です。

```ruby
stub_api_client_all(
  ExampleApiClient,
  request: { id: 12345 }
)

response = ExampleApiClient.new.request(user_id: 1)
response.id # => 12345
```


リクスエストパラメータを使ったレスポンスを返すようにスタブ化したい場合は、 `Proc` を利用することで実現できます。

```ruby
stub_api_client_all(
  ExampleApiClient,
  request: ->(params) { { id: params[:user_id] } }
)

response = ExampleApiClient.new.request(user_id: 1)
response.id # => 1
```

`receive` や `have_received` を使ったテストを書きたい場合は、 `stub_api_client_all` や `stub_api_client` の戻り値を利用すると良いでしょう。

```ruby
def execute_api_request
  ExampleApiClient.new.request(user_id: 1)
end

api_clinet = stub_api_client_all(ExampleApiClient, request: nil)
execute_api_request
expect(api_client).to have_received(:request).with(user_id: 1)
```

また、例外が発生する場合のテストを書きたい場合は、 `raise` オプションを利用することができます。

```ruby
def execute_api_request
  ExampleApiClient.new.request(user_id: 1)
end

stub_api_client_all(ExampleApiClient, request: { raise: MyApiClient::Error })
expect { execute_api_request }.to raise_error(MyApiClient::Error)
```

なお、発生した例外に含まれるレスポンスパラメータもスタブ化したい場合は、 `response` オプションと同時に指定することが可能です。

```ruby
stub_api_client_all(
  ExampleApiClient,
  request: {
    raise: MyApiClient::Error,
    response: { message: 'error' }
  }
)

begin
  ExampleApiClient.new.request(user_id: 1)
rescue MyApiClient::Error => e
  response_body = e.params.response.data.to_h
  expect(response_body).to eq(message: 'error')
end
```

## Deployment

この gem のリリースには [gem_comet](https://github.com/ryz310/gem_comet) を利用しています。
`gem_comet` の README.md にも使い方が載っていますが、備忘録のため、こちらにもリリースフローを記載しておきます。

### Preparement

以下のコマンドで `.envrc` を作成し、 `GITHUB_ACCESS_TOKEN` を設定します。

```sh
$ cp .envrc.skeleton .envrc
```

以下のコマンドで `gem_comet` をインストールします。

```sh
$ gem install gem_comet
```

### USAGE

以下のコマンドで、最後のリリースから現在までに merge した PR の一覧を確認できます。

```sh
$ gem_comet changelog
```

以下のコマンドで gem のリリースを実行します。
`{VERSION}` には新しく付与するバージョン番号を指定します。

```sh
$ gem_comet release {VERSION}
```

実行すると、 https://github.com/ryz310/my_api_client/pulls に以下のような PR が作成されます。

* [Update v0\.16\.1](https://github.com/ryz310/my_api_client/pull/297)
* [Release v0\.16\.1](https://github.com/ryz310/my_api_client/pull/298)

まず、 `Update v{VERSION}`  という PR から merge に取り掛かります。

PR のコメントにも TODO が記載されていますが、まず、バージョン番号が正しく採番されているかを確認します。

See: [314a4c0](https://github.com/ryz310/my_api_client/pull/297/commits/314a4c06f66324ce77b640b1ee8db5c84ee038a2)

次に `CHANGELOG.md` を編集して、 CHANGELOG を見やすく整理します。

See: [33a2d17](https://github.com/ryz310/my_api_client/pull/297/commits/33a2d1703c773813c837e74ee3181906b2f2e502)

これらが整ったら、 `Update v{VERSION}`  を merge します。

これでリリース準備が整ったので、`Release v{VERSION}`  の merge に取り掛かります。

この PR にこれからリリースする gem に対する変更が全て載っています。
変更内容の最終確認をして、 CI も通ったことを確認したら `Release v{VERSION}`  を merge します。

あとは Circle CI 側で gem のリリースが自動実行されるので、暫く待ちましょう。

お疲れさまでした :tea:

## Contributing

不具合の報告や Pull Request を歓迎しています。OSS という事で自分はなるべく頑張って英語を使うようにしていますが、日本語での報告でも大丈夫です :+1:
