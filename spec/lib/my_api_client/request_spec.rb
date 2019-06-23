# frozen_string_literal: true

RSpec.describe MyApiClient::Request do
  class self::MockClass
    include MyApiClient::Request
    include MyApiClient::Config
    include MyApiClient::Exceptions
    include MyApiClient::ErrorHandling

    if ActiveSupport::VERSION::STRING >= '5.2.0'
      class_attribute :error_handlers, default: []
    else
      class_attribute :error_handlers
      self.error_handlers = []
    end

    endpoint 'https://example.com/v1'
    http_open_timeout 2.seconds
    http_read_timeout 3.seconds

    private

    def bad_request(_params, _logger)
      puts 'The method is called'
    end
  end

  describe '#_request' do
    subject(:request!) do
      instance._request(:get, '/path/to/resource', headers, query, body, logger)
    end

    before do
      allow(MyApiClient::Params::Request).to receive(:new).and_call_original
      allow(MyApiClient::Params::Params).to receive(:new).and_call_original
      allow(MyApiClient::Logger).to receive(:new).and_return(request_logger)
      allow(Sawyer::Agent).to receive(:new).and_return(agent)
      allow(Faraday).to receive(:new).and_call_original
      allow(instance).to receive(:error_handling).and_call_original
      stub_request(:get, 'https://example.com/v1/path/to/resource')
        .with(query: query)
        .to_return(body: response_body, headers: headers)
    end

    let(:instance) { self.class::MockClass.new }
    let(:headers) { { 'Content-Type': 'application/json;charset=UTF-8' } }
    let(:query) { { key: 'value' } }
    let(:body) { nil }
    let(:response_body) { { message: 'OK' }.to_json }
    let(:agent) { instance_double(Sawyer::Agent, call: response) }
    let(:response) do
      instance_double(Sawyer::Response, status: 200, data: resource, timing: 0.1, headers: nil)
    end
    let(:resource) { instance_double(Sawyer::Resource) }
    let(:logger) { instance_double(::Logger) }
    let(:request_logger) { instance_double(MyApiClient::Logger, info: nil, warn: nil, error: nil) }

    it 'builds request parameter instance with arguments' do
      request!
      expect(MyApiClient::Params::Request)
        .to have_received(:new).with(:get, '/v1/path/to/resource', headers, query, body)
    end

    it 'builds a request logger instandce with arguments' do
      request!
      expect(MyApiClient::Logger)
        .to have_received(:new)
        .with(logger, instance_of(Faraday::Connection), :get, '/v1/path/to/resource')
    end

    it 'builds Sawyer::Agent instance with the configuration parameter' do
      request!
      expect(Sawyer::Agent)
        .to have_received(:new)
        .with('https://example.com', faraday: instance_of(Faraday::Connection))
    end

    it 'builds Faraday instance with configuration parameters' do
      request!
      expect(Faraday)
        .to have_received(:new)
        .with(nil, request: { timeout: 3.seconds, open_timeout: 2.seconds })
    end

    it 'initializes in order of faraday, sawyer, logger' do
      request!
      expect(Faraday).to have_received(:new).ordered
      expect(Sawyer::Agent).to have_received(:new).ordered
      expect(MyApiClient::Logger).to have_received(:new).ordered
    end

    it 'calls Sawyer::Agent#call with request parameters' do
      request!
      expect(agent)
        .to have_received(:call)
        .with(:get, '/v1/path/to/resource', body, headers: headers, query: query)
    end

    it 'builds the Params instance with request and response parameters' do
      request!
      expect(MyApiClient::Params::Params)
        .to have_received(:new)
        .with(instance_of(MyApiClient::Params::Request), response)
    end

    it 'calls #error_handling with response parameters' do
      request!
      expect(instance).to have_received(:error_handling).with(response)
    end

    it 'returns HTTP request response' do
      expect(request!).to eq resource
    end

    context 'when #error_handling returns Proc' do
      before { allow(instance).to receive(:error_handling).and_return(proc) }

      let(:proc) { ->(_params, _request_logger) { puts 'The procedure is called' } }

      it 'calls received procedure' do
        expect { request! }.to output("The procedure is called\n").to_stdout
      end
    end

    context 'when #error_handling returns Symbol' do
      before { allow(instance).to receive(:error_handling).and_return(:bad_request) }

      it 'executes received Symbol\'s method' do
        expect { request! }.to output("The method is called\n").to_stdout
      end
    end

    context 'when detects some network error' do
      before { allow(agent).to receive(:call).and_raise(Net::OpenTimeout) }

      it 'raises MyApiClient::NetworkError' do
        expect { request! }.to raise_error(MyApiClient::NetworkError)
      end
    end

    context 'when raises a error which inherit MyApiClient::Error' do
      before { allow(instance).to receive(:error_handling).and_return(proc) }

      let(:proc) { ->(params, _request_logger) { raise MyApiClient::Error, params } }

      it 'escalates the error' do
        expect { request! }.to raise_error(MyApiClient::Error)
      end
    end
  end
end
