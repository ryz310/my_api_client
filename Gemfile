# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# Workaound for ruby 2.4. Because activesupport v6.0.0 requires ruby 2.5 over.
gem 'activesupport', '< 6.0.3'

group :integrations, optional: true do
  gem 'bugsnag', '>= 6.11.0'
end

# Specify your gem's dependencies in my_api_client.gemspec
gemspec
