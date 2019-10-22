# frozen_string_literal: true

require 'my_api_client'
require 'my_api_client/rspec/matcher_helper'
require 'my_api_client/rspec/stub'
require 'my_api_client/rspec/matchers/be_handled_as_an_error'
require 'my_api_client/rspec/matchers/request_to'

RSpec.configure do |config|
  config.include MyApiClient::Stub
end
