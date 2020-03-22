# frozen_string_literal: true

require './example/api_clients/my_status_api_client'

RSpec.describe 'Integration test with My Status API', type: :integration do
  let(:api_client) { MyStatusApiClient.new }

  describe 'GET status/:status' do
    context 'with status code: 200' do
      it 'returns specified ID and message' do
        response = api_client.get_status(status: 200)
        expect(response.message).to eq 'You requested status code: 200'
      end
    end

    context 'with status code: 400' do
      it do
        expect { api_client.get_status(status: 400) }
          .to raise_error(MyErrors::BadRequest)
      end
    end

    context 'with status code: 401' do
      it do
        expect { api_client.get_status(status: 401) }
          .to raise_error(MyErrors::Unauthorized)
      end
    end

    context 'with status code: 403' do
      it do
        expect { api_client.get_status(status: 403) }
          .to raise_error(MyErrors::Forbidden)
      end
    end

    context 'with status code: 404' do
      it do
        expect { api_client.get_status(status: 404) }
          .to raise_error(MyApiClient::ClientError::NotFound)
      end
    end

    context 'with status code: 500' do
      it do
        expect { api_client.get_status(status: 500) }
          .to raise_error(MyApiClient::ServerError::InternalServerError)
      end
    end
  end
end
