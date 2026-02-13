# AGENTS.md (rails_app)

## Rails Verification App Policy
- For a new Rails major/minor verification environment, generate it with `rails new` first instead of copying from another version directory.
- Keep the generated app close to Rails defaults, then apply only the minimum project-specific changes needed for CI verification.
- Minimum project-specific changes:
  - Add `gem 'my_api_client', path: '../..'` to the app Gemfile.
  - Add `gem 'rspec-rails'` and required `spec/` helpers so `verify_generator` can run RSpec.
  - For Ruby 4.0+ compatibility in generator verification, add `gem 'benchmark'` and `gem 'cgi'` to the app Gemfile when required by Rails/runtime.
  - Remove nested `.git` created by `rails new` under `rails_app/rails_*`.
- Development baseline rule in this repository also applies here:
  - Use the oldest supported Ruby/Rails major-minor.
  - Patch versions can be the latest available within that baseline.
