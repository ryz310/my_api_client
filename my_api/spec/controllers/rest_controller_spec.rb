# frozen_string_literal: true

describe RestController, type: :controller do
  describe '#index' do
    let(:expected_response) do
      [{ id: 1 }, { id: 2 }, { id: 3 }].to_json
    end

    it 'returns a success response' do
      get '/rest'
      expect(response.status).to eq 200
      expect(response.body).to eq expected_response
    end
  end

  describe '#show' do
    let(:expected_response) do
      { id: 123, message: 'The resource is readed.' }.to_json
    end

    it 'returns a success response' do
      get '/rest/:id', id: 123
      expect(response.status).to eq 200
      expect(response.body).to eq expected_response
    end
  end

  describe '#create' do
    let(:expected_response) do
      { id: 1, message: 'The resource is created.' }.to_json
    end

    it 'returns a success response' do
      post '/rest'
      expect(response.status).to eq 201
      expect(response.body).to eq expected_response
    end
  end

  describe '#update' do
    let(:expected_response) do
      { id: 123, message: 'The resource is updated.' }.to_json
    end

    it 'returns a success response' do
      patch '/rest/:id', id: 123
      expect(response.status).to eq 200
      expect(response.body).to eq expected_response
    end
  end

  describe '#delete' do
    let(:expected_response) do
      { id: 123, message: 'The resource is deleted.' }.to_json
    end

    it 'returns a success response' do
      delete '/rest/:id', id: 123
      expect(response.status).to eq 204
      expect(response.body).to be_empty
    end
  end
end
