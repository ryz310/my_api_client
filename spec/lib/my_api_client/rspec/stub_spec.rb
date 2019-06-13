# frozen_string_literal: true

require 'my_api_client/rspec/stub'

RSpec.describe MyApiClient::Stub do
  include described_class

  class self::ExampleApiClient < MyApiClient::Base
    endpoint 'https://example.com'

    def request(user_id:)
      get "users/#{user_id}"
    end
  end

  let(:api_request!) do
    self.class::ExampleApiClient.new.request(user_id: 1)
  end

  describe '#my_api_client_stub' do
    context 'when use `response` option' do
      it 'stubs ApiClient as that returns parameters set by `response` on executes' do
        my_api_client_stub(self.class::ExampleApiClient, :request, response: { id: 12_345 })
        response = self.class::ExampleApiClient.new.request(user_id: 1)
        expect(response.id).to eq 12_345
      end
    end

    context 'when use `block`' do
      it 'stubs the ApiClient as that returns parameters set by `block` on executes' do
        my_api_client_stub(self.class::ExampleApiClient, :request) do |params|
          { id: params[:user_id] }
        end
        response = self.class::ExampleApiClient.new.request(user_id: 1)
        expect(response.id).to eq 1
      end
    end

    context 'when use `raise` option' do
      context 'with MyApiClient::Error class' do
        it 'stubs ApiClient as that raises Error set by `raise` on executes' do
          my_api_client_stub(
            self.class::ExampleApiClient,
            :request,
            raise: MyApiClient::ClientError
          )
          expect { api_request! }.to raise_error(MyApiClient::ClientError)
        end
      end

      context 'with MyApiClient::NetworkError class' do
        it 'stubs ApiClient as that raises Error set by `raise` on executes' do
          my_api_client_stub(
            self.class::ExampleApiClient,
            :request,
            raise: MyApiClient::NetworkError
          )
          expect { api_request! }.to raise_error(MyApiClient::NetworkError)
        end
      end

      context 'with MyApiClient::Error instance' do
        it 'stubs ApiClient as that raises Error set by `raise` on executes' do
          params = instance_double(MyApiClient::Params::Params, metadata: {})
          error = MyApiClient::ServerError.new(params)
          my_api_client_stub(self.class::ExampleApiClient, :request, raise: error)
          expect { api_request! }.to raise_error(MyApiClient::ServerError)
        end
      end

      context 'with MyApiClient::Error instance' do
        it 'raises exception' do
          expect { my_api_client_stub(self.class::ExampleApiClient, :request, raise: 1) }
            .to raise_error(/Unsupported error class was set/)
        end
      end
    end

    describe 'return value' do
      it 'returns a spy object for the ApiClient' do
        api_client = my_api_client_stub(self.class::ExampleApiClient, :request)
        api_request!
        expect(api_client).to have_received(:request).with(user_id: 1)
      end
    end
  end
end
