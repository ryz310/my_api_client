# frozen_string_literal: true

require 'my_api_client/rspec/stub'

RSpec.describe MyApiClient::Stub do
  include described_class

  let(:example_api_client) do
    Class.new(MyApiClient::Base) do
      endpoint 'https://example.com'

      def request(user_id:)
        get "users/#{user_id}"
      end

      def request_all
        get 'users'
      end
    end
  end

  describe '#stub_api_client_all' do
    subject(:stubbing_all!) do
      stub_api_client_all(
        example_api_client,
        request: { id: 1 },
        request_all: [{ id: 1 }, { id: 2 }, { id: 3 }]
      )
    end

    it 'stubs all instance of the ApiClient' do
      stubbing_all!
      10.times do |i|
        api_client = example_api_client.new
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
          example_api_client,
          request: { id: 1 },
          request_all: [{ id: 1 }, { id: 2 }, { id: 3 }]
        )
    end

    it 'returns the response of the calling #stub_api_client' do
      api_client = instance_double('api_client') # rubocop:disable RSpec/VerifiedDoubleReference
      allow(self).to receive(:stub_api_client).and_return(api_client)
      expect(stubbing_all!).to eq api_client
    end
  end

  describe '#stub_api_client' do
    context 'when use Proc' do
      let(:api_client) do
        stub_api_client(
          example_api_client,
          request: ->(params) { { id: params[:user_id] } },
          request_all: -> { [{ id: 20 }, { id: 10 }, { id: 30 }].sort_by { |v| v[:id] } }
        )
      end

      let(:number) { rand(100) }

      it 'executes the procedure and returns the result' do
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
            example_api_client,
            request: { raise: error },
            request_all: { raise: error }
          )
        end

        it 'raises an arbitrary error set in the `raise` option' do
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
          error = MyApiClient::ServerError.new
          stub_api_client(
            example_api_client,
            request: { raise: error },
            request_all: { raise: error }
          )
        end

        it 'raises an arbitrary error set in the `raise` option' do
          expect { api_client.request(user_id: 1) }.to raise_error(MyApiClient::ServerError)
          expect { api_client.request_all }.to raise_error(MyApiClient::ServerError)
        end
      end

      context 'with not an MyApiClient::Error class or instance' do
        let(:api_client) do
          stub_api_client(
            example_api_client,
            request: { raise: 1 },
            request_all: { raise: 2 }
          )
        end

        it 'raises a runtime error' do
          expect { api_client.request(user_id: 1) }
            .to raise_error(/Unsupported error class was set/)
          expect { api_client.request_all }
            .to raise_error(/Unsupported error class was set/)
        end
      end
    end

    context 'when use `response` option' do
      let(:api_client) do
        stub_api_client(
          example_api_client,
          request: { response: { id: 12_345 } },
          request_all: { response: '' }
        )
      end

      it 'returns stub response body set in the `response` option' do
        response1 = api_client.request(user_id: 1)
        expect(response1.id).to eq 12_345
        response2 = api_client.request_all
        expect(response2).to eq ''
      end
    end

    context 'when use `raise`, `respones` and `status_code` options' do
      shared_examples 'a stub to raise an error' do |error|
        let(:api_client) do
          stub_api_client(
            example_api_client,
            request: { raise: error, response: { message: 'error 1' }, status_code: 404 },
            request_all: { raise: error, response: { message: 'error 2' } }
          )
        end

        it 'raises an arbitrary error set in the `raise` option' do
          expect { api_client.request(user_id: 1) }.to raise_error(error)
          expect { api_client.request_all }.to raise_error(error)
        end

        it 'returns stub response body set in the `response` option' do
          api_client.request(user_id: 1)
        rescue error => e
          response_body = e.params.response.data.to_h
          expect(response_body).to eq(message: 'error 1')
        end

        it 'returns stub status code set in the `status_code` option' do
          api_client.request(user_id: 1)
        rescue error => e
          status_code = e.params.response.status
          expect(status_code).to eq(404)
        end

        it 'returns status code 400 if you omit the `status_code` option' do
          api_client.request_all
        rescue error => e
          status_code = e.params.response.status
          expect(status_code).to eq(400)
        end

        it 'returns stub metadata set in the options' do
          api_client.request(user_id: 1)
        rescue error => e
          expect(e.params.metadata).to eq(
            duration: 0.123,
            response_body: { message: 'error 1' },
            response_headers: {},
            response_status: 404
          )
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
          error = MyApiClient::ServerError.new
          stub_api_client(
            example_api_client,
            request: { raise: error, response: { message: 'error 1' } },
            request_all: { raise: error, response: { message: 'error 2' } }
          )
        end

        it 'stubs to raise error set in `raise`' do
          expect { api_client.request(user_id: 1) }
            .to raise_error(/the `response` option is ignored/)
          expect { api_client.request_all }
            .to raise_error(/the `response` option is ignored/)
        end
      end

      context 'with not an MyApiClient::Error class or instance' do
        let(:api_client) do
          stub_api_client(
            example_api_client,
            request: { raise: 1 },
            request_all: { raise: 2 }
          )
        end

        it 'raises exception' do
          expect { api_client.request(user_id: 1) }
            .to raise_error(/Unsupported error class was set/)
          expect { api_client.request_all }
            .to raise_error(/Unsupported error class was set/)
        end
      end
    end

    context 'when use `pageable` option' do
      let(:api_client) do
        stub_api_client(
          example_api_client,
          request: {
            pageable: [
              { response: { page: 1 } },
              { page: 2 },
              ->(params) { { page: 3, user_id: params[:user_id] } },
              { raise: MyApiClient::ClientError::IamTeapot },
            ],
          },
          request_all: {
            pageable: Enumerator.new do |y|
              loop.with_index(1) do |_, i|
                y << { page: i }
              end
            end,
          }
        )
      end

      it 'stubs to pageable response' do # rubocop:disable RSpec/MultipleExpectations
        pageable_response = api_client.request(user_id: 1)
        response_1st_page = pageable_response.next
        expect(response_1st_page.page).to eq 1

        response_2nd_page = pageable_response.next
        expect(response_2nd_page.page).to eq 2

        response_3rd_page = pageable_response.next
        expect(response_3rd_page.page).to eq 3
        expect(response_3rd_page.user_id).to eq 1

        expect { pageable_response.next }.to raise_error(MyApiClient::ClientError::IamTeapot)
      end

      it 'is able to be endless pageable response' do
        expect { |b| api_client.request_all.take(5).map(&:page).each(&b) }
          .to yield_successive_args(1, 2, 3, 4, 5)
      end
    end

    context 'when use other values' do
      let(:api_client) do
        stub_api_client(
          example_api_client,
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
