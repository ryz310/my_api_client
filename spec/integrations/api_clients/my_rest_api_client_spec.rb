# frozen_string_literal: true

require './example/api_clients/my_rest_api_client'

RSpec.describe 'Integration test with My REST API', type: :integration do
  let(:api_client) { MyRestApiClient.new }

  describe 'GET rest' do
    context 'with order: :asc' do
      it 'returns an array of posts ordered by id' do
        response = api_client.get_posts(order: :asc)
        expect(response[0].id).to eq 1
        expect(response[1].id).to eq 2
        expect(response[2].id).to eq 3
      end
    end

    context 'with order: :desc' do
      it 'returns an array of posts reverse ordered by id' do
        response = api_client.get_posts(order: :desc)
        expect(response[0].id).to eq 3
        expect(response[1].id).to eq 2
        expect(response[2].id).to eq 1
      end
    end
  end

  describe 'GET rest/:id' do
    it 'returns a post' do
      response = api_client.get_post(id: 2)
      expect(response.id).to eq 2
      expect(response.title).to eq 'Title 2'
    end
  end

  describe 'POST rest' do
    it 'returns a created post' do
      response = api_client.post_post(title: 'New title')
      expect(response.id).to eq 4
      expect(response.title).to eq 'New title'
    end
  end

  describe 'PUT rest/:id' do
    it 'returns a updated post' do
      response = api_client.put_post(id: 3, title: 'Modified title')
      expect(response.id).to eq 3
      expect(response.title).to eq 'Modified title'
    end
  end

  describe 'PATCH rest/:id' do
    it 'returns a updated post' do
      response = api_client.patch_post(id: 3, title: 'Modified title')
      expect(response.id).to eq 3
      expect(response.title).to eq 'Modified title'
    end
  end

  describe 'DELETE rest/:id' do
    it 'returns no contents' do
      response = api_client.delete_post(id: 1)
      expect(response).to be_nil
    end
  end
end
