# frozen_string_literal: true

require './example/api_clients/my_rest_api_client'
require 'my_api_client/rspec'

RSpec.describe 'Integration test with My REST API', type: :integration do
  shared_examples 'the API client' do
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

  context 'with real connection' do
    let(:api_client) { MyRestApiClient.new }

    it_behaves_like 'the API client'
  end

  context 'with stubbed API client' do
    let(:api_client) do
      stub_api_client(
        MyRestApiClient,
        get_posts:,
        get_post: ->(params) { { id: params[:id], title: "Title #{params[:id]}" } },
        post_post: { response: { id: 4, title: 'New title' } },
        put_post: ->(params) { { id: params[:id], title: params[:title] } },
        patch_post: ->(params) { { id: params[:id], title: params[:title] } },
        delete_post: nil
      )
    end

    let(:get_posts) do
      lambda do |params|
        (1..3).map { |id| { id: } }.tap { |me| me.reverse! if params[:order] == :desc }
      end
    end

    it_behaves_like 'the API client'
  end
end
