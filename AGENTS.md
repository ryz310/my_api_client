# AGENTS.md

## Branch Creation Rule
- Always create a new branch from `master`.
- Before creating a branch, update local `master` with the latest commits from `origin`.
- Example flow:
  1. `git checkout master`
  2. `git fetch origin`
  3. `git pull --ff-only origin master`
  4. `git checkout -b codex/<new-branch-name>`

## Development Version Policy
- In development environments, always use the oldest versions among currently supported Ruby and Rails.
- Current baseline: Ruby 3.2 and Rails 7.1.
- Patch versions may be updated to the latest available releases within the selected baseline (e.g., Ruby 3.2.x and Rails 7.1.x).
- When updating support policy, also update `.ruby-version`, `Dockerfile` (`ARG RUBY_VERSION` and `BUNDLE_GEMFILE`), and development Dockerfiles under `rails_app/`.

## Docker Development Commands
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
- Run RuboCop:
  - `docker run --rm -it -v "$PWD":/app -w /app my_api_client-dev bundle exec rubocop`
- Build gem package:
  - `docker run --rm -it -v "$PWD":/app -w /app my_api_client-dev bundle exec rake build`
- Install gem locally in container:
  - `docker run --rm -it -v "$PWD":/app -w /app my_api_client-dev bundle exec rake install`
