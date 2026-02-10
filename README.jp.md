[![CircleCI](https://circleci.com/gh/ryz310/my_api_client.svg?style=svg)](https://circleci.com/gh/ryz310/my_api_client)
[![Gem Version](https://badge.fury.io/rb/my_api_client.svg)](https://badge.fury.io/rb/my_api_client)
[![Maintainability](https://api.codeclimate.com/v1/badges/861a2c8f168bbe995107/maintainability)](https://codeclimate.com/github/ryz310/my_api_client/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/861a2c8f168bbe995107/test_coverage)](https://codeclimate.com/github/ryz310/my_api_client/test_coverage)

English docs: [README.md](README.md)

# MyApiClient

`my_api_client` は Ruby on Rails / Ruby 向けの API クライアントビルダーです。
Sawyer + Faraday をベースに、次の機能を提供します。

- リクエスト DSL (`get`, `post`, `patch`, `put`, `delete`, `pageable_get`)
- レスポンス内容で判定できるエラーハンドリング DSL (`error_handling`)
- リトライ/破棄フック (`retry_on`, `discard_on`)
- RSpec 用のスタブ/カスタムマッチャ

## 対応バージョン

- Ruby: 3.1, 3.2, 3.3
- Rails: 6.1, 7.0, 7.1, 7.2

## インストール

```ruby
gem 'my_api_client'
```

Rails の場合は generator でひな形を作れます。

```sh
rails g api_client path/to/resource get:path/to/resource --endpoint https://example.com
```

## クイックスタート

```ruby
class ExampleApiClient < MyApiClient::Base
  endpoint 'https://example.com/v1'

  def get_users(condition:)
    get 'users', query: { search: condition }
  end
end

api_client = ExampleApiClient.new
api_client.get_users(condition: 'john')
```

## ドキュメント

- [はじめに](docs/ja/01-getting-started.md)
- [基本的な使い方とページネーション](docs/ja/02-usage.md)
- [エラーハンドリング](docs/ja/03-error-handling.md)
- [リトライ・タイムアウト・ロガー](docs/ja/04-retry-timeout-logger.md)
- [RSpec ヘルパーとマッチャ](docs/ja/05-rspec.md)
- [開発とリリース](docs/ja/06-development.md)

## Contributing

不具合報告・PR は歓迎です。
<https://github.com/ryz310/my_api_client>

## License

[MIT License](https://opensource.org/licenses/MIT) です。

## Code of Conduct

[CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) をご確認ください。
