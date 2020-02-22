# frozen_string_literal: true

RSpec.describe MyApiClient::Request do
  class self::MockClass
    include MyApiClient::Request
    include MyApiClient::Config
    include MyApiClient::Exceptions

    endpoint 'https://example.com/v1'

    http_open_timeout 2.seconds
    http_read_timeout 3.seconds

    attr_reader :logger

    def initialize
      @logger = ::Logger.new(STDOUT)
    end
  end

  described_class::HTTP_METHODS.each do |http_method|
    describe "##{http_method}" do
      subject(:execute) do
        instance.public_send(http_method, pathname, headers: headers, query: query, body: body)
      end

      let(:instance) { self.class::MockClass.new }
      let(:pathname) { 'path/to/resource' }
      let(:headers) { { 'Content-Type': 'application/json;charset=UTF-8' } }
      let(:request_params) { instance_double(MyApiClient::Params::Request) }
      let(:request_logger) { instance_double(MyApiClient::Request::Logger) }
      let(:response) { instance_double(Sawyer::Response, data: resource) }
      let(:resource) { instance_double(Sawyer::Resource) }

      if http_method == :get
        let(:query) { { key: 'value' } }
        let(:body) { nil }
        let(:uri) { URI.parse('https://example.com/v1/path/to/resource?key=value') }
      else
        let(:query) { nil }
        let(:body) { { name: 'John', birth: Date.today } }
        let(:uri) { URI.parse('https://example.com/v1/path/to/resource') }
      end

      before do
        allow(MyApiClient::Params::Request).to receive(:new).and_return(request_params)
        allow(MyApiClient::Request::Logger).to receive(:new).and_return(request_logger)
        allow(MyApiClient::Request::Executor).to receive(:call).and_return(response)
      end

      it 'builds a request parameter instance with arguments' do
        execute
        expect(MyApiClient::Params::Request)
          .to have_received(:new).with(http_method, uri, headers, body)
      end

      it 'builds a request logger instance with specified logger and arguments' do
        execute
        expect(MyApiClient::Request::Logger)
          .to have_received(:new).with(instance.logger, http_method, uri)
      end

      it 'calls the request executor class with builded instances' do
        execute
        expect(MyApiClient::Request::Executor).to have_received(:call).with(
          instance: instance,
          request_params: request_params,
          request_logger: request_logger,
          faraday_options: { request: { timeout: 3.seconds, open_timeout: 2.seconds } }
        )
      end

      it 'returns a return value of the request executor class' do
        expect(execute).to eq resource
      end
    end
  end
end
