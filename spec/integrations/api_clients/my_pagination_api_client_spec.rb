# frozen_string_literal: true

require './example/api_clients/my_pagination_api_client'
require 'my_api_client/rspec'

RSpec.describe 'Integration test with My Pagination API', type: :integration do
  describe 'GET pagination' do
    describe 'paging with JSONPath' do
      subject(:request_with_pagination) { api_client.paging_with_jsonpath.to_a }

      context 'with real connection' do
        let(:api_client) { MyPaginationApiClient.new }

        it 'returns an array of posts ordered by id' do
          request_with_pagination.each.with_index(1) do |response, idx|
            expect(response.page).to eq idx
          end
        end
      end

      context 'with stubbed API client' do
        let(:api_client) do
          stub_api_client(
            MyPaginationApiClient,
            paging_with_jsonpath: {
              pageable: [
                { page: 1 },
                { page: 2 },
                { page: 3 },
              ],
            }
          )
        end

        it 'returns an array of posts ordered by id' do
          request_with_pagination.each.with_index(1) do |response, idx|
            expect(response.page).to eq idx
          end
        end
      end
    end

    describe 'paging with Proc' do
      subject(:request_with_pagination) { api_client.paging_with_proc.to_a }

      context 'with real connection' do
        let(:api_client) { MyPaginationApiClient.new }

        it 'returns an array of posts ordered by id' do
          request_with_pagination.each.with_index(1) do |response, idx|
            expect(response.page).to eq idx
          end
        end
      end

      context 'with stubbed API client' do
        let(:api_client) do
          stub_api_client(
            MyPaginationApiClient,
            paging_with_proc: {
              pageable: [
                { page: 1 },
                { page: 2 },
                { page: 3 },
              ],
            }
          )
        end

        it 'returns an array of posts ordered by id' do
          request_with_pagination.each.with_index(1) do |response, idx|
            expect(response.page).to eq idx
          end
        end
      end
    end
  end
end
