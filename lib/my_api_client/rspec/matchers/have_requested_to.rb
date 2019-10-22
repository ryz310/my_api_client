# frozen_string_literal: true

require 'rspec/expectations'
require 'webmock/rspec'

RSpec::Matchers.define :have_requested_to do |expected_method, expected_url|
  include MyApiClient::MatcherHelper

  match do |api_request|
    disable_logging
    @expected = {
      method: expected_method,
      url: expected_url,
      body: expected_options[:body],
      headers: expected_options[:headers],
      query: expected_options[:query],
    }.compact
    @actual = {}
    sawyer = instance_double(Sawyer::Agent)
    allow(Sawyer::Agent).to receive(:new) do |schema_and_hostname|
      @actual_schema_and_hostname = schema_and_hostname
    end.and_return(sawyer)
    allow(sawyer).to receive(:call) do |method, pathname, body, options|
      @actual =
        {
          method: method,
          url: @actual_schema_and_hostname + pathname,
          body: body,
          headers: options[:headers],
          query: options[:query],
        }.compact
    end.and_return(dummy_response)
    api_request.call
    @expected == @actual
  end

  chain :with, :expected_options

  failure_message do |_|
    <<~MESSAGE
      expected that #{@actual} would match #{@expected}
      Diff: #{diff_as_object(@actual, @expected)}
    MESSAGE
  end

  supports_block_expectations
end
