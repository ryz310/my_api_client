# frozen_string_literal: true

describe StatusController, type: :controller do
  describe '#show' do
    context 'when request status code 200' do
      let(:status) { 200 }

      let(:expected_response) do
        { message: 'You requested status code: 200' }.to_json
      end

      it 'returns 200 OK' do
        get '/status/:status', status: status
        expect(response.status).to eq status
        expect(response.body).to eq expected_response
      end
    end

    context 'when request status code 400' do
      let(:status) { 400 }

      let(:expected_response) do
        { message: 'You requested status code: 400' }.to_json
      end

      it 'returns 400 Bad request' do
        get '/status/:status', status: status
        expect(response.status).to eq status
        expect(response.body).to eq expected_response
      end
    end

    context 'when request status code 500' do
      let(:status) { 500 }

      let(:expected_response) do
        { message: 'You requested status code: 500' }.to_json
      end

      it 'returns 500 Internal server error' do
        get '/status/:status', status: status
        expect(response.status).to eq status
        expect(response.body).to eq expected_response
      end
    end
  end
end
