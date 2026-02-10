# はじめに

## インストール

```ruby
gem 'my_api_client'
```

## Rails Generator

```sh
rails g api_client path/to/resource get:path/to/resource --endpoint https://example.com
```

以下のようなファイルが生成されます。

- `app/api_clients/application_api_client.rb`
- `app/api_clients/path/to/resource_api_client.rb`
- `spec/api_clients/path/to/resource_api_client_spec.rb`

## 最小構成

```ruby
class ApplicationApiClient < MyApiClient::Base
  endpoint 'https://example.com/v1'
end
```

共通の `endpoint`、`logger`、エラーハンドリングは親クラスで定義すると運用しやすいです。
