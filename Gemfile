# frozen_string_literal: true

# cooldown: skip gem versions published within the last 7 days to reduce the
# risk of pulling in a compromised or broken release right after publication.
source 'https://rubygems.org', cooldown: 7

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

group :integrations, optional: true do
  gem 'bugsnag', '>= 6.19.0'
end

# Specify your gem's dependencies in my_api_client.gemspec
gemspec
