# frozen_string_literal: true

RSpec.describe MyApiClient::Params::Request do
  let(:request) { described_class.new(method, url, headers, query, body) }
  let(:method) { 'GET' }
  let(:url) { 'path/to/resource' }
  let(:headers) { { 'Content-Type': 'application/json; charset=utf-8' } }
  let(:query) { { key: 'value' } }
  let(:body) { nil }

  describe '#to_sawyer_args' do
    subject { request.to_sawyer_args }

    it 'returns value formatted for arguments of Sawyer::Agent#call' do
      expect(request.to_sawyer_args).to eq [
        'GET',
        'path/to/resource',
        nil,
        {
          headers: { 'Content-Type': 'application/json; charset=utf-8' },
          query: { key: 'value' }
        }
      ]
    end
  end
end
