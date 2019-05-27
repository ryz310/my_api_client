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

WIP

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
  def request(name)
    post 'users', headers: headers, body: { name: name }
  end
end
```

### Timeout

WIP

## Contributing

不具合の報告や Pull Request を歓迎しています。OSS という事で自分はなるべく頑張って英語を使うようにしていますが、日本語での報告でも大丈夫です :+1:
