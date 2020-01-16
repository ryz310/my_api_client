# frozen_string_literal: true

require 'rspec/expectations'

RSpec::Matchers.define :be_handled_as_an_error do |expected_error_class|
  include MyApiClient::MatcherHelper

  match do |api_request|
    init
    set_validation_for_retry_count
    handle_error(api_request).is_a? expected_error_class
  end

  match_when_negated do |api_request|
    init
    handle_error(api_request).nil?
  end

  chain :after_retry, :retry_count
  chain(:times) { nil }
  chain :when_receive, :expected_response

  description do
    message = "be handled as #{expected_error_class || 'an error'}"
    message += " after retry #{retry_count} times" unless retry_count.nil?
    message
  end

  failure_message do |api_request|
    actual_error = handle_error(api_request)
    if actual_error.nil?
      "expected to be handled as #{expected_error_class.name}, " \
      'but not to be handled'
    else
      "expected to be handled as #{expected_error_class.name}, " \
      "but it was handled as #{actual_error.class.name}"
    end
  end

  failure_message_when_negated do |api_request|
    actual_error = handle_error(api_request)
    'expected not to be handled as an error, ' \
    "but it was handled as #{actual_error.class.name}"
  end

  attr_reader :sawyer

  def init
    disable_logging
    response = dummy_response(
      status: expected_response[:status_code] || 200,
      headers: expected_response[:headers] || {},
      body: expected_response[:body] || nil
    )
    @sawyer = instance_double(Sawyer::Agent, call: response)
    allow(Sawyer::Agent).to receive(:new).and_return(sawyer)
    allow(MyApiClient::Sleeper).to receive(:call)
  end

  def set_validation_for_retry_count
    return if retry_count.nil?

    expect(sawyer).to receive(:call).exactly(retry_count + 1).times
  end

  def handle_error(api_request)
    api_request.call
  rescue MyApiClient::Error => e
    e
  else
    nil
  end

  supports_block_expectations
end
