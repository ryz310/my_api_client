# frozen_string_literal: true

RSpec.describe MyApiClient::Request::Basic do
  described_class::HTTP_METHODS.each do |http_method|
    describe "##{http_method}" do
      let(:mock_class) do
        Class.new do
          include MyApiClient::Request::Basic
          include MyApiClient::Exceptions

          def _request_with_relative_uri(http_method, pathname, headers, query, body); end
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
      else
        let(:query) { nil }
        let(:body) { { name: 'John', birth: Date.today } }
      end

      before do
        allow(instance).to receive(:_request_with_relative_uri).and_return(response)
      end

      context 'without a block' do
        subject(:execute) do
          instance.public_send(http_method, pathname, headers: headers, query: query, body: body)
        end

        it 'calls the request method with relative URL' do
          execute
          expect(instance).to have_received(:_request_with_relative_uri)
            .with(http_method, pathname, headers, query, body)
        end

        it 'returns a response body object' do
          expect(execute).to eq resource
        end
      end

      context 'with a block' do
        subject(:execute) do
          instance.public_send(
            http_method,
            pathname,
            headers: headers,
            query: query,
            body: body
          ) do |response|
            response
          end
        end

        it 'calls the request method with relative URL' do
          execute
          expect(instance).to have_received(:_request_with_relative_uri)
            .with(http_method, pathname, headers, query, body)
        end

        it 'passes the sawyer response to the block parameter' do
          expect { |b| instance.public_send(http_method, pathname, &b) }
            .to yield_with_args(response)
        end

        it 'returns the block result' do
          expect(instance.public_send(http_method, pathname) { |_| 'a return value of block' })
            .to eq 'a return value of block'
        end
      end
    end
  end
end
