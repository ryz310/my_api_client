# リトライ・タイムアウト・ロガー

## リトライ

```ruby
class ExampleApiClient < MyApiClient::Base
  endpoint 'https://example.com'

  error_handling json: { '$.errors.code': 20 },
                 raise: MyApiClient::ApiLimitError,
                 retry: { wait: 30.seconds, attempts: 3 }
end
```

補足:

- `retry: true` で既定のリトライ設定を使えます
- `retry` を使う場合は `raise` が必須です
- ブロック付き `error_handling` と `retry` の併用はできません

`MyApiClient::NetworkError` には標準で `retry_on` が定義されています。

## ネットワークエラー

`MyApiClient::NetworkError` は低レイヤの例外をラップし、`#original_error` を参照できます。

```ruby
begin
  api_client.get_users(condition: 'john')
rescue MyApiClient::NetworkError => e
  e.original_error
  e.params.response # nil
end
```

## タイムアウト

```ruby
class ExampleApiClient < MyApiClient::Base
  endpoint 'https://example.com'
  http_read_timeout 10
  http_open_timeout 5
end
```

## ロガー

```ruby
class ExampleApiClient < MyApiClient::Base
  self.logger = Rails.logger
end
```

リクエストごとに次のようなログが出力されます。

- `Start`
- `Duration ... msec`
- `Success (...)` または `Failure (...)`
