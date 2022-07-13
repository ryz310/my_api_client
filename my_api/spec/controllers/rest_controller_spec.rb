# frozen_string_literal: true

describe RestController, type: :controller do
  describe '#index' do
    context 'with order = asc' do
      let(:array_of_posts) do
        [
          { id: 1, title: 'Title 1' },
          { id: 2, title: 'Title 2' },
          { id: 3, title: 'Title 3' },
        ].to_json
      end

      it 'returns an array of posts ordered by id' do
        get '/rest', order: 'asc'
        expect(response.status).to eq 200
        expect(response.body).to eq array_of_posts
      end
    end

    context 'with order = desc' do
      let(:array_of_posts) do
        [
          { id: 3, title: 'Title 3' },
          { id: 2, title: 'Title 2' },
          { id: 1, title: 'Title 1' },
        ].to_json
      end

      it 'returns an array of posts reverse ordered by id' do
        get '/rest', order: 'desc'
        expect(response.status).to eq 200
        expect(response.body).to eq array_of_posts
      end
    end
  end

  describe '#show' do
    let(:post) do
      { id: 1, title: 'Title 1' }.to_json
    end

    it 'returns a post' do
      get '/rest/:id', id: 1
      expect(response.status).to eq 200
      expect(response.body).to eq post
    end
  end

  describe '#create' do
    let(:new_post) do
      { id: 4, title: 'New title' }.to_json
    end

    it 'returns a created post' do
      post '/rest', title: 'New title'
      expect(response.status).to eq 201
      expect(response.body).to eq new_post
    end
  end

  describe '#update' do
    let(:the_post) do
      { id: 1, title: 'Modified title' }.to_json
    end

    context 'with POST method' do
      it 'returns a updated post' do
        post '/rest/:id', id: 1, title: 'Modified title'
        expect(response.status).to eq 200
        expect(response.body).to eq the_post
      end
    end

    context 'with PUT method' do
      it 'returns a updated post' do
        put '/rest/:id', id: 1, title: 'Modified title'
        expect(response.status).to eq 200
        expect(response.body).to eq the_post
      end
    end

    context 'with PATCH method' do
      it 'returns a updated post' do
        patch '/rest/:id', id: 1, title: 'Modified title'
        expect(response.status).to eq 200
        expect(response.body).to eq the_post
      end
    end
  end

  describe '#delete' do
    it 'returns no body' do
      delete '/rest/:id', id: 123
      expect(response.status).to eq 204
      expect(response.body).to be_empty
    end
  end
end
