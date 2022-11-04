# frozen_string_literal: true

describe HeaderController do
  describe '#index' do
    context 'when request header with a header' do
      let(:headers) { { 'x-header': 'value' } }

      it 'returns 200 OK request with header' do
        get '/header', query: headers
        expect(response.status).to eq 200
        expect(response.body).to eq '{}'
        expect(response.headers['x-header']).to eq 'value'
      end
    end

    context 'when request header with multiple headers' do
      let(:headers) do
        {
          'x-header': 'value1',
          'x-second-header': 'value2',
        }
      end

      it 'returns 200 OK request with header' do
        get '/header', query: headers
        expect(response.status).to eq 200
        expect(response.body).to eq '{}'
        expect(response.headers['x-header']).to eq 'value1'
        expect(response.headers['x-second-header']).to eq 'value2'
      end
    end
  end
end
