# frozen_string_literal: true

describe ErrorController do
  describe '#show' do
    context 'when request error code 10' do
      let(:code) { 10 }

      let(:expected_response) do
        {
          error: {
            code: code,
            message: 'You requested error code: 10',
          },
        }.to_json
      end

      it 'returns 400 Bad request with error code 10' do
        get '/error/:code', code: code
        expect(response.status).to eq 400
        expect(response.body).to eq expected_response
      end
    end

    context 'when request error code 20' do
      let(:code) { 20 }

      let(:expected_response) do
        {
          error: {
            code: code,
            message: 'You requested error code: 20',
          },
        }.to_json
      end

      it 'returns 400 Bad request with error code 20' do
        get '/error/:code', code: code
        expect(response.status).to eq 400
        expect(response.body).to eq expected_response
      end
    end
  end
end
