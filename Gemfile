# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem 'activesupport', '~> 6.1' # TODO: Remove this line at the end of Ruby 2.6 support

group :integrations, optional: true do
  gem 'bugsnag', '>= 6.11.0'
end

# Specify your gem's dependencies in my_api_client.gemspec
gemspec
