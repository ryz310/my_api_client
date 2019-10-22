# frozen_string_literal: true

require 'rspec/expectations'

RSpec::Matchers.define :request_to do |expected_method, expected_url|
  include MyApiClient::MatcherHelper

  match do |api_request|
    disable_logging
    @expected = {
      request_line: request_line(expected_method, expected_url),
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
          request_line: request_line(method, @actual_schema_and_hostname + pathname),
          body: body,
          headers: options[:headers],
          query: options[:query],
        }.compact
    end.and_return(dummy_response)
    api_request.call
    @expected == @actual
  end

  chain :with, :expected_options

  description do
    "request to \"#{request_line(expected_method, expected_url)}\""
  end

  failure_message do
    <<~MESSAGE
      expected to request to "#{@expected[:request_line]}"
      Diff: #{diff_as_object(@actual, @expected)}
    MESSAGE
  end

  def request_line(method, url)
    "#{method.upcase} #{url}"
  end

  supports_block_expectations
end
