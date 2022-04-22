# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

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

  config.before :each, type: :integration do
    WebMock.disable_net_connect!(allow: /#{ENV.fetch('MY_API_ENDPOINT', nil)}*/)
  end

  config.after :each, type: :integration do
    WebMock.disable_net_connect!
  end
end
