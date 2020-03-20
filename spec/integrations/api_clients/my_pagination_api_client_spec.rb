# frozen_string_literal: true

require './example/api_clients/my_pagination_api_client'

RSpec.describe 'Integration test with My Pagination API', type: :integration do
  let(:api_client) { MyPaginationApiClient.new }

  describe 'GET pagination' do
    it 'returns an array of posts ordered by id' do
      pageable_get = api_client.pagination
      expect(pageable_get.next.page).to eq 1
      expect(pageable_get.next.page).to eq 2
      expect(pageable_get.next.page).to eq 3
    end
  end
end
