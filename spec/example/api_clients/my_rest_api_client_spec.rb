# frozen_string_literal: true

require 'my_api_client/rspec'
require './example/api_clients/my_rest_api_client'

RSpec.describe MyRestApiClient, type: :api_client do
  let(:api_client) { described_class.new }
  let(:id) { rand(100) }

  let(:endpoint) { ENV['MY_API_ENDPOINT'] }
  let(:headers) do
    { 'Content-Type': 'application/json;charset=UTF-8' }
  end

  shared_examples 'to handle errors' do
    it do
      expect { api_request! }
        .to be_handled_as_an_error(MyApiClient::ClientError)
        .when_receive(status_code: 400)
    end

    it do
      expect { api_request! }
        .to be_handled_as_an_error(MyApiClient::ServerError)
        .when_receive(status_code: 500)
    end
  end

  describe '#get_all_id' do
    subject(:api_request!) { api_client.get_all_id }

    it 'requests to "GET rest"' do
      expect { api_request! }
        .to request_to(:get, URI.join(endpoint, 'rest'))
        .with(headers: headers)
    end

    it_behaves_like 'to handle errors' do
      it do
        expect { api_request! }
          .not_to be_handled_as_an_error
          .when_receive(status_code: 201, body: nil)
      end
    end
  end

  describe '#get_id' do
    subject(:api_request!) { api_client.get_id(id: id) }

    it 'requests to "GET rest/:id' do
      expect { api_request! }
        .to request_to(:get, URI.join(endpoint, "rest/#{id}"))
        .with(headers: headers)
    end

    it_behaves_like 'to handle errors' do
      it do
        expect { api_request! }
          .not_to be_handled_as_an_error
          .when_receive(status_code: 201, body: nil)
      end
    end
  end

  describe '#post_id' do
    subject(:api_request!) { api_client.post_id }

    it 'requests to "POST rest"' do
      expect { api_request! }
        .to request_to(:post, URI.join(endpoint, 'rest'))
        .with(headers: headers)
    end

    it_behaves_like 'to handle errors' do
      it do
        expect { api_request! }
          .not_to be_handled_as_an_error
          .when_receive(status_code: 201, body: nil)
      end
    end
  end

  describe '#patch_id' do
    subject(:api_request!) { api_client.patch_id(id: id) }

    it 'requests to "PATCH rest/:id"' do
      expect { api_request! }
        .to request_to(:patch, URI.join(endpoint, "rest/#{id}"))
        .with(headers: headers)
    end

    it_behaves_like 'to handle errors' do
      it do
        expect { api_request! }
          .not_to be_handled_as_an_error
          .when_receive(status_code: 201, body: nil)
      end
    end
  end

  describe '#delete_id' do
    subject(:api_request!) { api_client.delete_id(id: id) }

    it 'requests to "DELETE rest/:id"' do
      expect { api_request! }
        .to request_to(:delete, URI.join(endpoint, "rest/#{id}"))
        .with(headers: headers)
    end

    it_behaves_like 'to handle errors' do
      it do
        expect { api_request! }
          .not_to be_handled_as_an_error
          .when_receive(status_code: 201, body: nil)
      end
    end
  end
end
