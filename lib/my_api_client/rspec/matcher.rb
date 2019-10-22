# frozen_string_literal: true

require 'rspec/expectations'
require 'webmock/rspec'

RSpec::Matchers.define :have_requested_to do |expected_method, expected_url|
  match do |api_request|
    logger = instance_double(MyApiClient::Logger, info: nil, warn: nil)
    allow(MyApiClient::Logger).to receive(:new).and_return(logger)
    response = instance_double(
      Sawyer::Response,
      timing: 0.0,
      data: instance_double(Sawyer::Resource),
      status: 200,
      headers: {},
      body: nil
    )
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
    end.and_return(response)
    api_request.call
    @expected == @actual
  end

  chain :with, :expected_options
  end

  supports_block_expectations
end

RSpec::Matchers.define :handle_error do |expected_error_handling|
  match do |api_request|
    begin
      api_request.call
    rescue StandardError => e
      if expected_error_handling[:raise]
        e.is_a? expected_error_handling[:raise]
      else
        true
      end
    else
      false
    end
  end

  chain :when_receive do |api_response|
    logger = instance_double(MyApiClient::Logger, info: nil, warn: nil)
    allow(MyApiClient::Logger).to receive(:new).and_return(logger)
    response = instance_double(
      Sawyer::Response,
      timing: 0.0,
      data: instance_double(Sawyer::Resource),
      status: api_response[:status_code] || 200,
      headers: api_response[:headers] || {},
      body: api_response[:body] || nil
    )
    sawyer = instance_double(Sawyer::Agent, call: response)
    allow(Sawyer::Agent).to receive(:new).and_return(sawyer)
  end

  supports_block_expectations
end
