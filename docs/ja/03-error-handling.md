# エラーハンドリング

## 基本定義

```ruby
class ExampleApiClient < MyApiClient::Base
  endpoint 'https://example.com'

  error_handling status_code: 400..499, raise: MyApiClient::ClientError
  error_handling status_code: 500..599, raise: MyApiClient::ServerError
end
```

主な matcher:

- `status_code`: `Integer`, `Range`, `Regexp`, `Symbol`
- `headers`: `Hash` の値に `String` または `Regexp`
- `json`: `Hash` の値に `String`, `Integer`, `Range`, `Regexp`, `Symbol`

## 追加処理

ブロックを使う例:

```ruby
error_handling status_code: 500..599, raise: MyApiClient::ServerError do |params, logger|
  logger.warn "Response Body: #{params.response&.body.inspect}"
end
```

`with:` でインスタンスメソッド呼び出しも可能:

```ruby
error_handling json: { '$.errors.code': 10..19 }, with: :log_error
```

## `forbid_nil`

```ruby
error_handling status_code: 200, json: :forbid_nil
```

本来ボディが返る想定の API で、空レスポンスをエラー扱いしたい場合に有効です。

## 例外オブジェクト (`MyApiClient::Error`)

この gem の例外は `MyApiClient::Error` を継承し、`#params` を持ちます。

```ruby
begin
  api_client.get_users(condition: 'john')
rescue MyApiClient::Error => e
  e.params.request
  e.params.response
end
```

`e.params.metadata`（または `e.metadata`）は外部ロギング連携に使えます。
