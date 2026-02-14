# AGENTS.md

## Branch Creation Rule
- Always create a new branch from `master`.
- Before creating a branch, update local `master` with the latest commits from `origin`.
- After updating local `master`, reload and re-read `AGENTS.md` before starting any new task.
- Example flow:
  1. `git checkout master`
  2. `git fetch origin`
  3. `git pull --ff-only origin master`
  4. Re-open `AGENTS.md` and confirm instructions
  5. `git checkout -b codex/<new-branch-name>`

## Development Version Policy
- In development environments, always use the oldest versions among currently supported Ruby and Rails.
- Current baseline: Ruby 3.2 and Rails 7.2.
- Patch versions may be updated to the latest available releases within the selected baseline (e.g., Ruby 3.2.x and Rails 7.2.x).
- When updating support policy, also update `.ruby-version`, `Dockerfile` (`ARG RUBY_VERSION` and `BUNDLE_GEMFILE`), and development Dockerfiles under `rails_app/`.

## Support Matrix Update Procedure
- Decide target support matrix first (Ruby and Rails versions to keep/add/remove).
- Update `my_api_client.gemspec`:
  - `required_ruby_version`
  - `activesupport` minimum version
- Update CI matrix in `.github/workflows/ci.yml`:
  - `build_gem.strategy.matrix.ruby_version` / `rails_version`
  - `verify_generator.strategy.matrix.ruby_version` / `rails_version`
  - update representative matrix-gated conditions (e.g. coverage/upload conditions) to the intended runtime/framework pair
- Check other workflows under `.github/workflows/` for fixed Ruby versions and align them when support policy changes.
- Update supported versions in:
  - `README.md`
  - `README.jp.md`
- Keep development baseline files aligned:
  - `.ruby-version`
  - `Dockerfile` (`ARG RUBY_VERSION`)
  - `rails_app/*/Dockerfile` (`ARG RUBY_VERSION`) for supported Rails verification apps
- Keep verification assets aligned with supported Rails:
  - remove unsupported `gemfiles/rails_*.gemfile`
  - remove unsupported `rails_app/rails_*` directories
  - keep only supported Rails verification app directories
- Validate before commit:
  - `docker run --rm -v "$PWD":/app -w /app my_api_client-dev bundle exec rspec`
  - `docker run --rm -v "$PWD":/app -w /app my_api_client-dev bundle exec rubocop`
  - `docker run --rm -v "$PWD":/app -w /app my_api_client-dev bundle exec rake build`
- If any `rails_app/rails_*/Gemfile.lock` drifts from gemspec constraints, sync at least the `my_api_client` entry (`version` and `activesupport` lower bound).

## Docker Development Commands
- Command selection policy:
  - Use `docker compose` for integration specs that require the `my_api` server.
  - Use `docker run` for lint, build, and non-integration spec execution.
- Build development image:
  - `docker build -t my_api_client-dev .`
- Open a shell in the container (mount local source):
  - `docker run --rm -it -v "$PWD":/app -w /app my_api_client-dev bash`
- Install/update gems:
  - `docker run --rm -it -v "$PWD":/app -w /app my_api_client-dev bundle install`
- Run all specs:
  - `docker run --rm -it -v "$PWD":/app -w /app my_api_client-dev bundle exec rspec`
- Run a specific spec file:
  - `docker run --rm -it -v "$PWD":/app -w /app my_api_client-dev bundle exec rspec spec/integrations/api_clients/my_rest_api_client_spec.rb`
- Run integration specs with real HTTP:
  - `docker compose up -d --build my_api`
  - `docker compose run --rm test bundle exec rspec spec/integrations/api_clients`
  - `docker compose down --volumes --remove-orphans`
- Run RuboCop:
  - `docker run --rm -it -v "$PWD":/app -w /app my_api_client-dev bundle exec rubocop`
- Build gem package:
  - `docker run --rm -it -v "$PWD":/app -w /app my_api_client-dev bundle exec rake build`
- Install gem locally in container:
  - `docker run --rm -it -v "$PWD":/app -w /app my_api_client-dev bundle exec rake install`

## Validation Rule
- Run RuboCop and confirm there are no offenses only when `.rb` files are changed.

## Retrospective Rule
- Propose a KPT retrospective when a task reaches a completion point, such as after creating a Pull Request.
- Based on the KPT results, propose updates to `AGENTS.md`.
- The timing of the retrospective may be decided by Codex when it is appropriate.
