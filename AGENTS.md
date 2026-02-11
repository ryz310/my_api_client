# AGENTS.md

## Branch Creation Rule
- Always create a new branch from `master`.
- Before creating a branch, update local `master` with the latest commits from `origin`.
- Example flow:
  1. `git checkout master`
  2. `git fetch origin`
  3. `git pull --ff-only origin master`
  4. `git checkout -b codex/<new-branch-name>`

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
