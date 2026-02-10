# RSpec ヘルパーとマッチャ

## セットアップ

`spec/spec_helper.rb` または `spec/rails_helper.rb` に追記:

```ruby
require 'my_api_client/rspec'
```

## リクエスト検証 (`request_to`)

```ruby
expect { api_client.get_users(condition: 'john') }
  .to request_to(:get, 'https://example.com/v1/users')
  .with(query: { search: 'john' })
```

## エラーハンドリング検証 (`be_handled_as_an_error`)

```ruby
expect { api_client.get_users(condition: 'john') }
  .to be_handled_as_an_error(MyApiClient::ClientError)
  .when_receive(status_code: 200, body: { errors: { code: 10 } }.to_json)
```

リトライ回数の検証:

```ruby
expect { api_client.get_users(condition: 'john') }
  .to be_handled_as_an_error(MyApiClient::ApiLimitError)
  .after_retry(3).times
  .when_receive(status_code: 200, body: { errors: { code: 20 } }.to_json)
```

## スタブ (`stub_api_client`, `stub_api_client_all`)

```ruby
stub_api_client_all(ExampleApiClient, request: { response: { id: 1 } })
ExampleApiClient.new.request(user_id: 10).id # => 1
```

アクションごとに指定できる主なオプション:

- 通常のレスポンス Hash
- `response:`
- `raise:`（例外クラスまたは例外インスタンス）
- `status_code:`（`raise:` と併用）
- `pageable:`（ページネーション向け Enumerable）
- `Proc`（入力値に応じた動的レスポンス）
