# frozen_string_literal: true

require 'my_api_client/rspec'
require './example/api_clients/my_header_api_client'

RSpec.describe MyHeaderApiClient, type: :api_client do
  let(:api_client) { described_class.new }
  let(:endpoint) { ENV.fetch('MY_API_ENDPOINT', nil) }
  let(:headers) do
    { 'Content-Type': 'application/json;charset=UTF-8' }
  end

  describe '#get_header' do
    subject(:api_request!) do
      api_client.get_header(first_header: first_header_value, second_header: second_header_value)
    end

    context 'when the query parameters are nil' do
      let(:first_header_value) { nil }
      let(:second_header_value) { nil }

      it 'requests to "GET header"' do
        expect { api_request! }
          .to request_to(:get, URI.join(endpoint, 'header'))
          .with(headers: headers)
      end
    end

    context 'when the query parameters is set' do
      let(:first_header_value) { 'first' }
      let(:second_header_value) { 'second' }

      it 'requests to "GET header" with query parameters' do
        uri = URI.join(endpoint, 'header')
        uri.query = URI.encode_www_form({ 'X-First-Header': 'first', 'X-Second-Header': 'second' })

        expect { api_request! }
          .to request_to(:get, uri)
          .with(headers: headers)
      end
    end

    describe 'error handling' do
      let(:response_headers) do
        {
          'X-First-Header': first_header_value,
          'X-Second-Header': second_header_value,
        }.compact
      end

      context 'when the first header contains invalid' do
        let(:first_header_value) { 'this is invalid header value' }
        let(:second_header_value) { nil }

        it do
          expect { api_request! }
            .to be_handled_as_an_error(MyErrors::FirstHeaderIsInvalid)
            .when_receive(headers: response_headers)
        end
      end

      context 'when the first header contains unknown' do
        let(:first_header_value) { 'this header value is unknown' }

        context 'when the second header contains error' do
          let(:second_header_value) { 'error has occurred' }

          it do
            expect { api_request! }
              .to be_handled_as_an_error(MyErrors::MultipleHeaderIsInvalid)
              .when_receive(headers: response_headers)
          end
        end

        context 'when the second header does not contain error' do
          let(:second_header_value) { 'ok' }

          it do
            expect { api_request! }
              .not_to be_handled_as_an_error(MyApiClient::ClientError)
              .when_receive(headers: response_headers)
          end
        end
      end

      context 'when the first header does not contain unknown' do
        let(:first_header_value) { 'ok' }

        context 'when the second header contains error' do
          let(:second_header_value) { 'error has occurred' }

          it do
            expect { api_request! }
              .not_to be_handled_as_an_error(MyApiClient::ClientError)
              .when_receive(headers: response_headers)
          end
        end
      end

      context 'when the first header has nothing' do
        let(:first_header_value) { 'nothing' }
        let(:second_header_value) { nil }

        context 'with status code: 404' do
          it do
            expect { api_request! }
              .to be_handled_as_an_error(MyErrors::FirstHeaderHasNothingAndNotFound)
              .when_receive(headers: response_headers, status_code: 404)
          end
        end

        context 'with status code: 401' do
          it 'is expected to be handled MyApiClient::ClientError by default error handlers' do
            expect { api_request! }
              .to be_handled_as_an_error(MyApiClient::ClientError::Unauthorized)
              .when_receive(headers: response_headers, status_code: 401)
          end
        end
      end
    end
  end
end
