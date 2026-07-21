# frozen_string_literal: true

require 'simplecov'
require 'simplecov_json_formatter'

SimpleCov.command_name(ENV.fetch('SIMPLECOV_COMMAND_NAME', 'my_api_rspec'))
SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::JSONFormatter,
]
SimpleCov.start

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end
