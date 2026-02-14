# My API

This is the API server for integration testing with `my_api_client`.

## APIs

### My Rest API

Simple REST endpoints that return fixed payloads used by integration tests.

- `GET /rest`
- `GET /rest/:id`
- `POST /rest`
- `PUT/PATCH /rest/:id`
- `DELETE /rest/:id`

### My Status API

Returns the requested status code and message.

- `GET /status/:status`

### My Header API

Echoes request headers in the response headers.

- `GET /header`

### My Error API

Returns fixed JSON error payloads for error handling tests.

- `GET /error/:code`

### My Pagination API

Returns paginated responses with `links.next` and `links.previous`.

- `GET /pagination?page=1`

## Local Development

```sh
bundle install
bundle exec rackup -o 0.0.0.0 -p 3000
```

## Run With Docker Compose

From repository root:

```sh
docker compose up -d --build my_api
docker compose run --rm my_api bundle exec rspec spec/requests
docker compose run --rm test bundle exec rspec
docker compose down --volumes --remove-orphans
```

Run only integration specs:

```sh
docker compose up -d --build my_api
docker compose run --rm test bundle exec rspec spec/integrations/api_clients
docker compose down --volumes --remove-orphans
```
