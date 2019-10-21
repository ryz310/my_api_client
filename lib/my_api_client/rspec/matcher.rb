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
    sawyer = instance_double(Sawyer::Agent)
    result = true
    allow(sawyer).to receive(:call) do |method, pathname, body, options|
      result =
        (expected_method == method) &&
        (@expected_pathname == pathname) &&
        (@expected_body == body) &&
        (@expected_headers == options[:headers]) &&
        (@expected_query == options[:query])
    end.and_return(response)
    allow(Sawyer::Agent).to receive(:new) do |schema_and_hostname|
      @expected_pathname = expected_url.sub(schema_and_hostname, '')
    end.and_return(sawyer)
    api_request.call
    result
  end

  chain :with do |expected_options|
    @expected_body = expected_options[:body]
    @expected_headers = expected_options[:headers]
    @expected_query = expected_options[:query]
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
