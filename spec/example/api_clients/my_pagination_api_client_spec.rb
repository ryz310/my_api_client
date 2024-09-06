# frozen_string_literal: true

require 'my_api_client/rspec'
require './example/api_clients/my_pagination_api_client'

RSpec.describe MyPaginationApiClient, type: :api_client do
  let(:api_client) { described_class.new }
  let(:endpoint) { ENV.fetch('MY_API_ENDPOINT', nil) }
  let(:headers) do
    { 'Content-Type': 'application/json;charset=UTF-8' }
  end

  shared_examples 'an API client' do
    it do
      expect { api_request! }
        .to request_to(:get, URI.join(endpoint, 'pagination'))
        .with(headers:, query: { page: 1 })
    end

    describe 'error handling' do
      it do
        expect { api_request! }
          .not_to be_handled_as_an_error
          .when_receive(status_code: 201, body: nil)
      end

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
  end

  describe '#paging_with_jsonpath' do
    subject(:api_request!) { api_client.paging_with_jsonpath.first }

    it_behaves_like 'an API client'
  end

  describe '#paging_with_proc' do
    subject(:api_request!) { api_client.paging_with_proc.first }

    it_behaves_like 'an API client'
  end
end
