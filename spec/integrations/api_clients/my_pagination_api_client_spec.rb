# frozen_string_literal: true

require './example/api_clients/my_pagination_api_client'
require 'my_api_client/rspec'

RSpec.describe 'Integration test with My Pagination API', type: :integration do
  describe 'GET pagination' do
    shared_examples 'the API client' do
      it 'returns an array of posts ordered by id' do
        pageable_get = api_client.pagination
        expect(pageable_get.next.page).to eq 1
        expect(pageable_get.next.page).to eq 2
        expect(pageable_get.next.page).to eq 3
      end
    end

    context 'with real connection' do
      let(:api_client) { MyPaginationApiClient.new }

      it_behaves_like 'the API client'
    end

    context 'with stubbed API client' do
      let(:api_client) do
        stub_api_client(
          MyPaginationApiClient,
          pagination: {
            pageable: [
              { page: 1 },
              { page: 2 },
              { page: 3 },
            ],
          }
        )
      end

      it_behaves_like 'the API client'
    end
  end
end
