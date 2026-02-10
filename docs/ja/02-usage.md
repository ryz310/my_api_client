# 基本的な使い方とページネーション

## 基本リクエスト DSL

```ruby
class ExampleApiClient < MyApiClient::Base
  endpoint 'https://example.com/v1'

  def get_users(condition:)
    get 'users', query: { search: condition }
  end

  def post_user(name:)
    post 'users', body: { name: name }
  end
end
```

利用できるメソッド:

- `get`
- `post`
- `put`
- `patch`
- `delete`

ブロックを渡さない場合、戻り値は `response.data` (`Sawyer::Resource`) です。

## ページネーション (`pageable_get` / `pget`)

```ruby
class MyPaginationApiClient < MyApiClient::Base
  endpoint 'https://example.com/v1'

  def users
    pageable_get 'users', paging: '$.links.next', query: { page: 1 }
  end
end

api_client = MyPaginationApiClient.new
api_client.users.take(3).each { |page| p page }
```

`paging` には次を指定できます。

- JSONPath 文字列
- `Proc`（次ページ URL の独自抽出）
