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

    context 'when the qurey parameters are nil' do
      let(:first_header_value) { nil }
      let(:second_header_value) { nil }

      it 'requests to "GET header"' do
        expect { api_request! }
          .to request_to(:get, URI.join(endpoint, 'header'))
          .with(headers: headers)
      end
    end

    context 'when the qurey parameters is set' do
      let(:first_header_value) { 'first' }
      let(:second_header_value) { 'second' }

      it 'requests to "GET header" with parameters' do
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

      context 'when the first header is invalid' do
        let(:first_header_value) { 'this is invalid header value' }
        let(:second_header_value) { nil }

        it do
          expect { api_request! }
            .to be_handled_as_an_error(MyErrors::FirstHeaderIsInvalid)
            .when_receive(headers: response_headers)
        end
      end

      context 'when the first header is zero' do
        let(:first_header_value) { 0 }
        let(:second_header_value) { nil }

        it do
          expect { api_request! }
            .to be_handled_as_an_error(MyErrors::FirstHeaderIs00)
            .when_receive(headers: response_headers)
        end
      end

      context 'when the first header is in 1xx' do
        let(:first_header_value) { rand(100..199) }
        let(:second_header_value) { nil }

        it do
          expect { api_request! }
            .to be_handled_as_an_error(MyErrors::FirstHeaderIs1xx)
            .when_receive(headers: response_headers)
        end
      end

      context 'when the first header is in 2xx and the second header is in 3xx' do
        let(:first_header_value) { rand(200..299) }
        let(:second_header_value) { rand(300..399) }

        it do
          expect { api_request! }
            .to be_handled_as_an_error(MyErrors::MultipleHeaderIsInvalid)
            .when_receive(headers: response_headers)
        end
      end

      context 'when the first header is in 2xx and the second header is out of 3xx' do
        let(:first_header_value) { rand(200..299) }
        let(:second_header_value) { 400 }

        it do
          expect { api_request! }
            .not_to be_handled_as_an_error(MyApiClient::ClientError)
            .when_receive(headers: response_headers)
        end
      end

      context 'when the first header is out of 2xx and the second header is in 3xx' do
        let(:first_header_value) { 300 }
        let(:second_header_value) { rand(300..399) }

        it do
          expect { api_request! }
            .not_to be_handled_as_an_error(MyApiClient::ClientError)
            .when_receive(headers: response_headers)
        end
      end


      context 'when the first header is 30' do
        let(:first_header_value) { 30 }
        let(:second_header_value) { nil }

        context 'with status code: 404' do
          it do
            expect { api_request! }
              .to be_handled_as_an_error(MyErrors::FirstHeaderIs30WithNotFound)
              .when_receive(headers: response_headers, status_code: 404)
          end
        end

        context 'without status code: 404' do
          it do
            expect { api_request! }
              .to be_handled_as_an_error(MyErrors::FirstHeaderIs30)
              .when_receive(headers: response_headers, status_code: 200)
          end
        end
      end

    end
  end
end
