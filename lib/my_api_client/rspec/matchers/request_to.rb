# frozen_string_literal: true

require 'rspec/expectations'

RSpec::Matchers.define :request_to do |expected_method, expected_url|
  include MyApiClient::MatcherHelper

  match do |api_request|
    disable_logging
    @expected = {
      request_line: request_line(expected_method, expected_url, expected_options[:query]),
      body: expected_options[:body],
      headers: expected_options[:headers],
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
        }.compact
    end.and_return(dummy_response)
    safe_execution(api_request)
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

  # To ignore error handling
  def safe_execution(api_request)
    api_request.call
  rescue MyApiClient::Error
    nil
  end

  def request_line(method, url, query = nil)
    url += '?' + query.to_query if query.present?
    "#{method.upcase} #{url}"
  end

  supports_block_expectations
end
