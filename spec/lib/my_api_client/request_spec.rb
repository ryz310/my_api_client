# frozen_string_literal: true

RSpec.describe MyApiClient::Request do
  describe '#_request' do
    subject(:request) { instance.send(:_request, http_method, uri, headers, body) }

    let(:mock_class) do
      Class.new do
        include MyApiClient::Request
        include MyApiClient::Config

        http_open_timeout 2.seconds
        http_read_timeout 3.seconds

        attr_reader :logger

        def initialize
          @logger = ::Logger.new(STDOUT)
        end
      end
    end

    let(:instance) { mock_class.new }

    let(:http_method) { :get }
    let(:uri) { URI.parse('https://example.com/v1/path/to/resource?key=value') }
    let(:headers) { { 'Content-Type': 'application/json;charset=UTF-8' } }
    let(:body) { { name: 'John', birth: Date.today } }

    let(:request_params) { instance_double(MyApiClient::Params::Request) }
    let(:request_logger) { instance_double(MyApiClient::Request::Logger) }
    let(:response) { instance_double(Sawyer::Response) }

    before do
      allow(MyApiClient::Params::Request).to receive(:new).and_return(request_params)
      allow(MyApiClient::Request::Logger).to receive(:new).and_return(request_logger)
      allow(MyApiClient::Request::Executor).to receive(:call).and_return(response)
    end

    it 'builds a request parameter instance with arguments' do
      request
      expect(MyApiClient::Params::Request)
        .to have_received(:new).with(http_method, uri, headers, body)
    end

    it 'builds a request logger instance with specified logger and arguments' do
      request
      expect(MyApiClient::Request::Logger)
        .to have_received(:new).with(instance.logger, http_method, uri)
    end

    it 'calls the request executor class with builded instances' do
      request
      expect(MyApiClient::Request::Executor).to have_received(:call).with(
        instance: instance,
        request_params: request_params,
        request_logger: request_logger,
        faraday_options: { request: { timeout: 3.seconds, open_timeout: 2.seconds } }
      )
    end

    it 'returns a return value of the request executor class' do
      expect(request).to eq response
    end
  end
end
