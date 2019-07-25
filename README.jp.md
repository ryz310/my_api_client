[![CircleCI](https://circleci.com/gh/ryz310/my_api_client.svg?style=svg)](https://circleci.com/gh/ryz310/my_api_client) [![Gem Version](https://badge.fury.io/rb/my_api_client.svg)](https://badge.fury.io/rb/my_api_client) [![Maintainability](https://api.codeclimate.com/v1/badges/861a2c8f168bbe995107/maintainability)](https://codeclimate.com/github/ryz310/my_api_client/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/861a2c8f168bbe995107/test_coverage)](https://codeclimate.com/github/ryz310/my_api_client/test_coverage)

# MyApiClient

MyApiClient は API リクエストクラスを作成するための汎用的な機能を提供します。Sawyer や Faraday をベースにエラーハンドリングの機能を強化した構造になっています。

ただし、 Sawyer はダミーデータの作成が難しかったり、他の gem で競合することがよくあるので、将来的には依存しないように変更していくかもしれません。

また、 Ruby on Rails で利用することを想定してますが、それ以外の環境でも動作するように作っているつもりです。不具合などあれば Issue ページからご報告下さい。

## Supported Versions

* Ruby 2.4, 2.5, 2.6
* Rails 4.2, 5.0, 5.1, 5.2

## Installation

この gem は macOS と Linux で作動します。まずは `my_api_client` を Gemfile に追加します:

```ruby
gem 'my_api_client'
```

Ruby on Rails を利用している場合は `generator` 機能を利用できます。

```sh
$ rails g api_client path/to/resource get:path/to/resource

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

### Error handling

上記のコードにエラーハンドリングを追加してみます。

```ruby
class ExampleApiClient < MyApiClient::Base
  endpoint 'https://example.com'

  error_handling status_code: 400..499, raise: MyApiClient::ClientError

  error_handling status_code: 500..599 do |params, logger|
    logger.warn 'Server error occurred.'
    raise MyApiClient::ServerError, params
  end

  error_handling json: { '$.errors.code': 10..19 }, with: :my_error_handling

  # Omission...

  private

  # @param params [MyApiClient::Params::Params] HTTP req and res params
  # @param logger [MyApiClient::Logger] Logger for a request processing
  def my_error_handling(params, logger)
    logger.warn "Response Body: #{params.response.body.inspect}"
    raise MyApiClient::ClientError, params
  end
end
```

一つずつ解説していきます。まず、以下のように `status_code` を指定するものについて。

```ruby
error_handling status_code: 400..499, raise: MyApiClient::ClientError
```

これは `ExampleApiClient` からのリクエスト全てにおいて、レスポンスのステータスコードが `400..499` であった場合に `MyApiClient::ClientError` が例外として発生するようになります。 `ExampleApiClient` を継承したクラスにもエラーハンドリングは適用されます。ステータスコードのエラーハンドリングは親クラスで定義すると良いと思います。

なお、 `status_code` には `Integer` `Range` `Regexp` が指定可能です。`raise` には `MyApiClient::Error` を継承したクラスが指定可能です。`my_api_client` で標準で定義しているエラークラスについては以下のソースコードをご確認下さい。

https://github.com/ryz310/my_api_client/blob/master/lib/my_api_client/errors.rb

次に、 `raise` の代わりに `block` を指定する場合について。

```ruby
error_handling status_code: 500..599 do |params, logger|
  logger.warn 'Server error occurred.'
  raise MyApiClient::ServerError, params
end
```

上記の例であれば、ステータスコードが `500..599` の場合に `block` の内容が実行れます。引数の `params` にはリクエスト情報とレスポンス情報が含まれています。`logger` はログ出力用インスタンスですが、このインスタンスを使ってログ出力すると、以下のようにリクエスト情報がログ出力に含まれるようになり、デバッグの際に便利です。

```text
API request `GET https://example.com/path/to/resouce`: "Server error occurred."
```

リクエストに失敗した場合は例外処理を実行する、という設計が一般的だと思われるので、基本的にブロックの最後に `raise` を実行する事になると思います。

最後に `json` と `with` を利用する場合について。

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

`with` にはインスタンスメソッド名を指定することで、エラーを検出した際に任意のメソッドを実行させることができます。メソッドに渡される引数は `block` 定義の場合と同じく `params` と `logger` です。

```ruby
# @param params [MyApiClient::Params::Params] HTTP req and res params
# @param logger [MyApiClient::Logger] Logger for a request processing
def my_error_handling(params, logger)
  logger.warn "Response Body: #{params.response.body.inspect}"
  raise MyApiClient::ClientError, params
end
```

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
error_handling status_code: 200, forbid_nil: true
```

一部のサービスではサーバーから何らかの Response Body が返ってくる事を期待しているにも関わらず、空の結果が結果が返ってくるというケースがあるようです。こちらも実験的な機能ですが、そういったケースを検出するために `forbid_nil` オプションを用意しました。通常の場合、Response Body が空の場合はエラー判定をしませんが、このオプションに `true` を指定するとエラーとして検知する様になります。正常応答が空となる API も存在するので、誤検知にご注意下さい。

#### MyApiClient::Params::Params

WIP

#### MyApiClient::Error

WIP

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

ただし、 `ActiveJob` とは異なり同期処理でリトライするため、ネットワークの瞬断に備えたリトライ以外ではあまり使う機会はないのではないかと思います。上記の例のように API Limit に備えてリトライするケースもあるかと思いますが、こちらは `ActiveJob` で対応した方が良いと思います。

ちなみに一応 `discard_on` も実装していますが、作者自身が有効な用途を見出せていないので、詳細は割愛します。良い利用方法があれば教えてください。

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

## Testing

### RSpec

RSpec を使ったテストをサポートしています。
以下のコードを `spec/spec_helper.rb` (または `spec/rails_helper.rb`) に追記して下さい。

```ruby
require 'my_api_client/rspec'
```

例えば以下のような `ApiClient` を定義しているとします。

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

## Contributing

不具合の報告や Pull Request を歓迎しています。OSS という事で自分はなるべく頑張って英語を使うようにしていますが、日本語での報告でも大丈夫です :+1:
