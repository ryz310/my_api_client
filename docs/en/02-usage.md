# Basic Usage and Pagination

## Basic Request DSL

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

Available methods:

- `get`
- `post`
- `put`
- `patch`
- `delete`

Each method returns `response.data` (`Sawyer::Resource`) unless you pass a block.

## Pagination (`pageable_get` / `pget`)

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

`paging` can be:

- JSONPath string (for response body)
- `Proc` (custom next-page extraction)
