# my_api AGENTS.md

## Current Stack Policy

- `my_api/` is a Rails 8.1 API-only application.
- Use the latest supported Ruby version for `my_api/`.
- Keep these files aligned when Ruby or runtime settings change:
  - `my_api/.ruby-version`
  - `my_api/Dockerfile`
  - `docker-compose.yml`
  - `.github/workflows/ci.yml` (integration job)

## API Compatibility Policy

- Keep endpoint behavior compatible with integration specs under `spec/integrations/api_clients/`.
- If endpoint behavior changes, update both:
  - `my_api/app/controllers/*`
  - related specs in `spec/integrations/api_clients/*_spec.rb`

## Test Execution Policy

- Run real HTTP integration tests with Docker Compose:
  1. `docker compose up -d --build my_api`
  2. `docker compose run --rm test`
  3. `docker compose down --volumes --remove-orphans`

## Implementation Scope Policy

- Do not reintroduce Ruby on Jets specific dependencies or configuration.
- Keep `my_api/` focused on fixture endpoints for `my_api_client` integration tests.
