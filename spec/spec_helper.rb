# frozen_string_literal: true

require 'simplecov'
require 'simplecov_json_formatter'

SimpleCov.command_name(ENV.fetch('SIMPLECOV_COMMAND_NAME', 'rspec'))
SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::JSONFormatter,
]
SimpleCov.start do
  add_filter '/rails_app/'
end

require 'pry'
require 'bundler/setup'
require 'webmock/rspec'
require 'my_api_client'

require_relative 'support/complete_about'
require_relative 'support/complete_within'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  my_api_endpoint = ENV.fetch('MY_API_ENDPOINT', '')

  if my_api_endpoint.empty?
    config.filter_run_excluding type: :integration
    config.filter_run_excluding file_path: %r{spec/example/api_clients/}

    config.before :suite do
      yellow = "\e[33m"
      reset = "\e[0m"
      RSpec.configuration.reporter.message(
        "#{yellow}[my_api_client] MY_API_ENDPOINT is not set. " \
        'Skipping specs with `type: :integration` and specs under ' \
        "`spec/example/api_clients/`.#{reset}"
      )
    end
  end

  config.before :each, type: :integration do
    if my_api_endpoint.empty?
      WebMock.disable_net_connect!
    else
      WebMock.disable_net_connect!(allow: /#{Regexp.escape(my_api_endpoint)}/)
    end
  end

  config.after :each, type: :integration do
    WebMock.disable_net_connect!
  end
end
