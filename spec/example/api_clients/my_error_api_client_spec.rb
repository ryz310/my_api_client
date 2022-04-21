# frozen_string_literal: true

require 'my_api_client/rspec'
require './example/api_clients/my_error_api_client'

RSpec.describe MyErrorApiClient, type: :api_client do
  let(:api_client) { described_class.new }
  let(:endpoint) { ENV.fetch('MY_API_ENDPOINT', nil) }
  let(:headers) do
    { 'Content-Type': 'application/json;charset=UTF-8' }
  end

  describe '#get_error' do
    subject(:api_request!) { api_client.get_error(code: code) }

    let(:code) { 10 }

    it 'requests to "GET error/:code' do
      expect { api_request! }
        .to request_to(:get, URI.join(endpoint, "error/#{code}"))
        .with(headers: headers)
    end

    describe 'error handling' do
      let(:response_body) do
        {
          error: {
            code: code,
            message: "You requested error code: #{code}",
          },
        }.to_json
      end

      context 'when returned error code is 0' do
        let(:code) { 0 }

        it do
          expect { api_request! }
            .to be_handled_as_an_error(MyErrors::ErrorCode00)
            .when_receive(body: response_body)
        end
      end

      context 'when returned error code is 10' do
        let(:code) { 10 }

        it do
          expect { api_request! }
            .to be_handled_as_an_error(MyErrors::ErrorCode10)
            .when_receive(body: response_body)
        end
      end

      context 'when returned error code is 20 to 29' do
        let(:code) { rand(20..29) }

        it do
          expect { api_request! }
            .to be_handled_as_an_error(MyErrors::ErrorCode2x)
            .when_receive(body: response_body)
        end
      end

      context 'when returned error code is 30' do
        let(:code) { 30 }

        context 'with status code: 400' do
          it do
            expect { api_request! }
              .to be_handled_as_an_error(MyErrors::ErrorCode30)
              .when_receive(body: response_body, status_code: 400)
          end
        end

        context 'without status code: 400' do
          it do
            expect { api_request! }
              .to be_handled_as_an_error(MyErrors::ErrorCodeOther)
              .when_receive(body: response_body, status_code: 404)
          end
        end
      end

      context 'when returned status code is 500' do
        it do
          expect { api_request! }
            .to be_handled_as_an_error(MyApiClient::ServerError)
            .when_receive(status_code: 500)
        end
      end
    end
  end
end
