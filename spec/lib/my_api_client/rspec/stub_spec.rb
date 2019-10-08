# frozen_string_literal: true

require 'my_api_client/rspec/stub'

RSpec.describe MyApiClient::Stub do
  include described_class

  class self::ExampleApiClient < MyApiClient::Base
    endpoint 'https://example.com'

    def request(user_id:)
      get "users/#{user_id}"
    end

    def request_all
      get 'users'
    end
  end

  describe '#stub_api_client_all' do
    subject(:stubbing_all!) do
      stub_api_client_all(
        self.class::ExampleApiClient,
        request: { id: 1 },
        request_all: [{ id: 1 }, { id: 2 }, { id: 3 }]
      )
    end

    it 'stubs all instance of the ApiClient' do
      stubbing_all!
      10.times do |i|
        api_client = self.class::ExampleApiClient.new
        response1 = api_client.request(user_id: i)
        expect(response1.id).to eq 1
        response2 = api_client.request_all
        expect(response2.map(&:id)).to eq [1, 2, 3]
      end
    end

    it 'calls #stub_api_client with received arguments' do
      allow(self).to receive(:stub_api_client)
      stubbing_all!
      expect(self)
        .to have_received(:stub_api_client)
        .with(
          self.class::ExampleApiClient,
          request: { id: 1 },
          request_all: [{ id: 1 }, { id: 2 }, { id: 3 }]
        )
    end

    it 'returns the response of the calling #stub_api_client' do
      api_client = instance_double('api client')
      allow(self).to receive(:stub_api_client).and_return(api_client)
      expect(stubbing_all!).to eq api_client
    end
  end

  describe '#stub_api_client' do
    context 'when use Proc' do
      let(:api_client) do
        stub_api_client(
          self.class::ExampleApiClient,
          request: ->(params) { { id: params[:user_id] } },
          request_all: -> { [{ id: 20 }, { id: 10 }, { id: 30 }].sort_by { |v| v[:id] } }
        )
      end

      let(:number) { rand(100) }

      it 'stubs the ApiClient to return params set in Proc' do
        response1 = api_client.request(user_id: number)
        expect(response1.id).to eq number
        response2 = api_client.request_all
        expect(response2.map(&:id)).to eq [10, 20, 30]
      end
    end

    context 'when use `raise` option' do
      shared_examples 'a stub to raise an error' do |error|
        let(:api_client) do
          stub_api_client(
            self.class::ExampleApiClient,
            request: { raise: error },
            request_all: { raise: error }
          )
        end

        it 'stubs ApiClient to raise error set in `raise`' do
          expect { api_client.request(user_id: 1) }.to raise_error(error)
          expect { api_client.request_all }.to raise_error(error)
        end
      end

      context 'with MyApiClient::Error class' do
        it_behaves_like 'a stub to raise an error', MyApiClient::ClientError
      end

      context 'with MyApiClient::NetworkError class' do
        it_behaves_like 'a stub to raise an error', MyApiClient::NetworkError
      end

      context 'with MyApiClient::Error instance' do
        let(:api_client) do
          params = instance_double(MyApiClient::Params::Params, metadata: {})
          error = MyApiClient::ServerError.new(params)
          stub_api_client(
            self.class::ExampleApiClient,
            request: { raise: error },
            request_all: { raise: error }
          )
        end

        it 'stubs ApiClient to raise error set in `raise`' do
          expect { api_client.request(user_id: 1) }.to raise_error(MyApiClient::ServerError)
          expect { api_client.request_all }.to raise_error(MyApiClient::ServerError)
        end
      end

      context 'with not an MyApiClient::Error class or instance' do
        let(:stubbing!) do
          stub_api_client(
            self.class::ExampleApiClient,
            request: { raise: 1 },
            request_all: { raise: 2 }
          )
        end

        it 'raises exception' do
          expect { stubbing! }.to raise_error(/Unsupported error class was set/)
        end
      end
    end

    context 'when use response option' do
      let(:api_client) do
        stub_api_client(
          self.class::ExampleApiClient,
          request: { response: { id: 12_345 } },
          request_all: { response: [10, 20, 30] }
        )
      end

      it 'stubs the ApiClient to return params set in `response`' do
        response1 = api_client.request(user_id: 1)
        expect(response1.id).to eq 12_345
        response2 = api_client.request_all
        expect(response2).to eq [10, 20, 30]
      end
    end

    context 'when use other values' do
      let(:api_client) do
        stub_api_client(
          self.class::ExampleApiClient,
          request: { id: 'alias' },
          request_all: nil
        )
      end

      it 'provides alias of `reponse` options' do
        response1 = api_client.request(user_id: 1)
        expect(response1.id).to eq 'alias'
        response2 = api_client.request_all
        expect(response2).to be_nil
      end
    end
  end
end
