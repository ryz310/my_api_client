# My API

This is the API server for integration testing with `my_api_client`.

## APIs

- `GET /rest`
- `GET /rest/:id`
- `POST /rest`
- `PUT/PATCH /rest/:id`
- `DELETE /rest/:id`
- `GET /status/:status`
- `GET /header`
- `GET /error/:code`
- `GET /pagination?page=1`

## Local Development

```sh
bundle install
bundle exec rails server -b 0.0.0.0 -p 3000
```
