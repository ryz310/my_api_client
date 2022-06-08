# frozen_string_literal: true

require 'my_api_client/rspec'
require './example/api_clients/my_status_api_client'

RSpec.describe MyStatusApiClient, type: :api_client do
  let(:api_client) { described_class.new }
  let(:endpoint) { ENV.fetch('MY_API_ENDPOINT', nil) }
  let(:headers) do
    { 'Content-Type': 'application/json;charset=UTF-8' }
  end

  describe '#get_status' do
    subject(:api_request!) { api_client.get_status(status: status) }

    shared_examples 'to handle errors' do
      context 'when returned status code is 400' do
        let(:status) { 400 }

        it do
          expect { api_request! }
            .to be_handled_as_an_error(MyErrors::BadRequest)
            .when_receive(status_code: 400)
        end
      end

      context 'when returned status code is 401' do
        let(:status) { 401 }

        it do
          expect { api_request! }
            .to be_handled_as_an_error(MyErrors::Unauthorized)
            .when_receive(status_code: 401)
        end
      end

      context 'when returned status code is 403' do
        let(:status) { 403 }

        it do
          expect { api_request! }
            .to be_handled_as_an_error(MyErrors::Forbidden)
            .when_receive(status_code: 403)
        end
      end

      context 'when returned status code is 404' do
        let(:status) { 404 }

        it do
          expect { api_request! }
            .to be_handled_as_an_error(MyApiClient::ClientError::NotFound)
            .when_receive(status_code: 404)
        end
      end

      context 'when returned status code is 500' do
        let(:status) { 500 }

        it do
          expect { api_request! }
            .to be_handled_as_an_error(MyApiClient::ServerError::InternalServerError)
            .when_receive(status_code: 500)
        end
      end
    end

    let(:status) { 200 }

    it 'requests to "GET status/:status' do
      expect { api_request! }
        .to request_to(:get, URI.join(endpoint, "status/#{status}"))
        .with(headers: headers)
    end

    it_behaves_like 'to handle errors' do
      it do
        expect { api_request! }
          .not_to be_handled_as_an_error
          .when_receive(status_code: 200, body: nil)
      end
    end
  end
end
