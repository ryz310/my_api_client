# frozen_string_literal: true

require 'spec_helper'
require 'dummy_app/api_clients/example_api_client'
require 'my_api_client/rspec'

RSpec.describe ExampleApiClient, type: :api_client do
  let(:api_client) { described_class.new(access_token: 'access_token') }
  let(:headers) do
    {
      'Content-Type': 'application/json;charset=UTF-8',
      'Authorization': 'Bearer access_token',
    }
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

    it do
      body = { errors: { code: 10 } }.to_json
      expect { api_request! }
        .to be_handled_as_an_error(MyApiClient::ClientError)
        .when_receive(status_code: 200, body: body)
    end

    it do
      body = { errors: { code: 20 } }.to_json
      expect { api_request! }
        .to be_handled_as_an_error(MyApiClient::ApiLimitError)
        .after_retry(2).times
        .when_receive(status_code: 200, body: body)
    end

    it do
      body = {
        errors: {
          code: 30,
          message: 'Sorry, something went wrong.',
        },
      }.to_json
      expect { api_request! }
        .to be_handled_as_an_error(MyApiClient::ServerError)
        .when_receive(status_code: 200, body: body)
    end
  end

  describe '#post_user' do
    subject(:api_request!) { api_client.post_user('Username') }

    it do
      expect { api_request! }
        .to request_to(:post, 'https://example.com/users')
        .with(headers: headers, body: { name: 'Username' })
    end

    it_behaves_like 'to handle errors' do
      it do
        body = { user: { id: 1, name: 'Username' } }.to_json
        expect { api_request! }
          .not_to be_handled_as_an_error.when_receive(status_code: 201, body: body)
      end
    end
  end

  describe '#get_users' do
    subject(:api_request!) { api_client.get_users }

    it do
      expect { api_request! }
        .to request_to(:get, 'https://example.com/users')
        .with(headers: headers)
    end

    it_behaves_like 'to handle errors' do
      it do
        body = {
          users: [
            { id: 1, name: 'User 1' },
            { id: 2, name: 'User 2' },
            { id: 3, name: 'User 3' },
          ],
        }.to_json
        expect { api_request! }
          .not_to be_handled_as_an_error.when_receive(status_code: 200, body: body)
      end
    end
  end

  describe '#patch_user' do
    subject(:api_request!) { api_client.patch_user(1, 'Modified') }

    it do
      expect { api_request! }
        .to request_to(:patch, 'https://example.com/users/1')
        .with(headers: headers, body: { name: 'Modified' })
    end

    it_behaves_like 'to handle errors' do
      it do
        body = { user: { id: 1, name: 'Modified' } }.to_json
        expect { api_request! }
          .not_to be_handled_as_an_error.when_receive(status_code: 200, body: body)
      end
    end
  end

  describe '#delete_user' do
    subject(:api_request!) { api_client.delete_user(1) }

    it do
      expect { api_request! }
        .to request_to(:delete, 'https://example.com/users/1')
        .with(headers: headers)
    end

    it_behaves_like 'to handle errors' do
      it do
        expect { api_request! }
          .not_to be_handled_as_an_error.when_receive(status_code: 200, body: {}.to_json)
      end
    end
  end
end
