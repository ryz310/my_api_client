# frozen_string_literal: true

require './example/api_clients/my_rest_api_client'

RSpec.describe 'Integration test with My REST API', type: :integration do
  let(:api_client) { MyRestApiClient.new }
  let(:id) { rand(100) }

  describe 'GET rest' do
    it 'returns array of ID' do
      response = api_client.get_all_id
      expect(response[0].id).to eq 1
      expect(response[1].id).to eq 2
      expect(response[2].id).to eq 3
    end
  end

  describe 'GET rest/:id' do
    it 'returns specified ID and message' do
      response = api_client.get_id(id: id)
      expect(response.id).to eq id
      expect(response.message).to eq 'The resource is readed.'
    end
  end

  describe 'POST rest' do
    it 'returns ID and message' do
      response = api_client.post_id
      expect(response.id).to eq 1
      expect(response.message).to eq 'The resource is created.'
    end
  end

  describe 'POST/PUT/PATCH rest/:id' do
    it 'returns specified ID and message' do
      response = api_client.patch_id(id: id)
      expect(response.id).to eq id
      expect(response.message).to eq 'The resource is updated.'
    end
  end

  describe 'DELETE rest/:id' do
    it 'returns no contents' do
      response = api_client.delete_id(id: id)
      expect(response).to be_nil
    end
  end
end
