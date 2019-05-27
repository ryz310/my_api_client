# MyApiClient

MyApiClient は API リクエストクラスを作成するための汎用的な機能を提供します。Sawyer や Faraday をベースにエラーハンドリングの機能を強化した構造になっています。ただし、 Sawyer はダミーデータの作成が難しかったり、他の gem で競合することがよくあるので、将来的には依存しないように変更していくかもしれません。

また、 Ruby on Rails で利用することを想定してますが、それ以外の環境でも動作するように作っているつもりです。不具合などあれば Issue ページからご報告下さい。

## Installation

この gem は macOS と Linux で作動します。まずは、my_api_client を Gemfile に追加します:

```ruby
gem 'my_api_client'
```

Ruby on Rails を利用している場合は `generator` 機能を利用できます。

```sh
$ rails g api_client path/to/resource https://example.com get_user:get:path/to/resource

create  app/api_clients/application_api_client.rb
create  app/api_clients/path/to/resource_api_client.rb
invoke  rspec
create    spec/api_clients/path/to/resource_api_client_spec.rb
```

## Usage

### Basic

最もシンプルな利用例を以下に示します。

```rb
class ExampleApiClient < MyApiClient::Base
  endpoint 'https://example.com'

  attr_reader :access_token

  def initialize(access_token:)
    @access_token = access_token
  end

  # GET https://example.com/users
  #
  # @return [Sawyer::Response] HTTP response parameter
  def get_users
    get 'users', query: { key: 'value' }, headers: headers
  end

  # POST https://example.com/users
  #
  # @param name [String] Username which want to create
  # @return [Sawyer::Response] HTTP response parameter
  def post_user(name)
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

クラス定義の最初に記述される `endpoint` にはリクエスト対象のスキーマとホストを定義します。ここにパス名を含めても反映されませんのでご注意ください。
次に、 `#initialize` を定義します。上記の例のように Access Token や API Key などを設定することを想定します。必要なければ定義の省略も可能です。
続いて、 `#get_users` や `#post_user` を定義します。メソッド名には API のタイトルを付けると良いと思います。メソッド内部で `#get` や `#post` を呼び出していますが、これがリクエスト時の HTTP Method になります。他にも `#patch` `#put` `#delete` が利用可能です。

### Error handling

上記のコードにエラーハンドリングを追加してみます。

```rb
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

```rb
error_handling status_code: 400..499, raise: MyApiClient::ClientError
```

これは `ExampleApiClient` からのリクエスト全てにおいて、レスポンスのステータスコードが `400..499` であった場合に `MyApiClient::ClientError` が例外として発生するようになります。 `ExampleApiClient` を継承したクラスにもエラーハンドリングは適用されます。ステータスコードのエラーハンドリングは親クラスで定義すると良いと思います。

なお、 `status_code` には `Integer` `Range` `Regexp` が指定可能です。`raise` には `MyApiClient::Error` を継承したクラスが指定可能です。`my_api_client` で標準で定義しているエラークラスについては以下のソースコードをご確認下さい。

https://github.com/ryz310/my_api_client/blob/master/lib/my_api_client/errors.rb

次に、 `raise` の代わりに Block を指定する場合について。

```rb
error_handling status_code: 500..599 do |params, logger|
  logger.warn 'Server error occurred.'
  raise MyApiClient::ServerError, params
end
```

上記の例であれば、ステータスコードが `500..599` の場合に Block の内容が実行れます。引数の `params` にはリクエスト情報とレスポンス情報が含まれています。`logger` はログ出力用インスタンスですが、このインスタンスを使ってログ出力すると、以下のようにリクエスト情報がログ出力に含まれるようになり、デバッグの際に便利です。

```text
API request `GET https://example.com/path/to/resouce`: "Server error occurred."
```

リクエストに失敗した場合は例外処理を実行する、という設計が一般的だと思われるので、基本的にブロックの最後に `raise` を実行する事になると思います。

最後に `json` と `with` を利用する場合について。

```rb
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

`with` にはインスタンスメソッド名を指定することで、エラーを検出した際に任意のメソッドを実行させることができます。メソッドに渡される引数は Block 定義の場合と同じく `params` と `logger` です。

```rb
# @param params [MyApiClient::Params::Params] HTTP req and res params
# @param logger [MyApiClient::Logger] Logger for a request processing
def my_error_handling(params, logger)
  logger.warn "Response Body: #{params.response.body.inspect}"
  raise MyApiClient::ClientError, params
end
```

### Retry

WIP

#### MyApiClient::NetworkError

WIP

### One request for one class

多くの場合、同一ホストの API は リクエストヘッダーやエラー情報が同じ構造になっているため、上記のように一つのクラス内に複数の API を定義する設計が理にかなっていますが、 API 毎に個別に定義したい場合は、以下のように 1 つのクラスに 1 の API という構造で設計することも可能です。

```rb
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

### Timeout

WIP

## Contributing

不具合の報告や Pull Request を歓迎しています。OSS という事で自分はなるべく頑張って英語を使うようにしていますが、日本語での報告でも大丈夫です :+1:
