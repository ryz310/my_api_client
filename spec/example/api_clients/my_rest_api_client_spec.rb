# frozen_string_literal: true

require 'my_api_client/rspec'
require './example/api_clients/my_rest_api_client'

RSpec.describe MyRestApiClient, type: :api_client do
  let(:api_client) { described_class.new }
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

  describe '#get_posts' do
    subject(:api_request!) { api_client.get_posts(order: order) }

    let(:order) { :asc }

    context 'with order: :asc' do
      it do
        expect { api_request! }
          .to request_to(:get, URI.join(endpoint, 'rest'))
          .with(headers: headers, query: { order: 'asc' })
      end
    end

    context 'with order: :desc' do
      let(:order) { :desc }

      it do
        expect { api_request! }
          .to request_to(:get, URI.join(endpoint, 'rest'))
          .with(headers: headers, query: { order: 'desc' })
      end
    end

    it_behaves_like 'to handle errors' do
      it do
        expect { api_request! }
          .not_to be_handled_as_an_error
          .when_receive(status_code: 201, body: nil)
      end
    end
  end

  describe '#get_post' do
    subject(:api_request!) { api_client.get_post(id: 1) }

    it 'requests to "GET rest/:id' do
      expect { api_request! }
        .to request_to(:get, URI.join(endpoint, 'rest/1'))
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

  describe '#post_post' do
    subject(:api_request!) { api_client.post_post(title: 'New title') }

    it 'requests to "POST rest"' do
      expect { api_request! }
        .to request_to(:post, URI.join(endpoint, 'rest'))
        .with(headers: headers, body: { title: 'New title' })
    end

    it_behaves_like 'to handle errors' do
      it do
        expect { api_request! }
          .not_to be_handled_as_an_error
          .when_receive(status_code: 201, body: nil)
      end
    end
  end

  describe '#put_post' do
    subject(:api_request!) { api_client.put_post(id: 1, title: 'Modified title') }

    it 'requests to "PATCH rest/:id"' do
      expect { api_request! }
        .to request_to(:put, URI.join(endpoint, 'rest/1'))
        .with(headers: headers, body: { title: 'Modified title' })
    end

    it_behaves_like 'to handle errors' do
      it do
        expect { api_request! }
          .not_to be_handled_as_an_error
          .when_receive(status_code: 201, body: nil)
      end
    end
  end

  describe '#patch_post' do
    subject(:api_request!) { api_client.patch_post(id: 1, title: 'Modified title') }

    it 'requests to "PATCH rest/:id"' do
      expect { api_request! }
        .to request_to(:patch, URI.join(endpoint, 'rest/1'))
        .with(headers: headers, body: { title: 'Modified title' })
    end

    it_behaves_like 'to handle errors' do
      it do
        expect { api_request! }
          .not_to be_handled_as_an_error
          .when_receive(status_code: 201, body: nil)
      end
    end
  end

  describe '#delete_post' do
    subject(:api_request!) { api_client.delete_post(id: 1) }

    it 'requests to "DELETE rest/:id"' do
      expect { api_request! }
        .to request_to(:delete, URI.join(endpoint, 'rest/1'))
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
