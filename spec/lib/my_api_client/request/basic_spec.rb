# frozen_string_literal: true

RSpec.describe MyApiClient::Request::Basic do
  described_class::HTTP_METHODS.each do |http_method|
    describe "##{http_method}" do
      subject(:execute) do
        instance.public_send(http_method, pathname, headers: headers, query: query, body: body)
      end

      let(:mock_class) do
        Class.new do
          include MyApiClient::Request::Basic
          include MyApiClient::Config
          include MyApiClient::Exceptions

          endpoint 'https://example.com/v1'

          def _request(http_method, uri, headers, body); end
        end
      end

      let(:instance) { mock_class.new }
      let(:pathname) { 'path/to/resource' }
      let(:headers) { { 'Content-Type': 'application/json;charset=UTF-8' } }
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

      before { allow(instance).to receive(:_request).and_return(response) }

      it 'calls the request executor class with builded instances' do
        execute
        expect(instance).to have_received(:_request)
          .with(http_method, uri, headers, body)
      end

      it 'returns a return value of the request executor class' do
        expect(execute).to eq resource
      end
    end
  end
end
