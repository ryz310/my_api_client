# frozen_string_literal: true

RSpec.describe MyApiClient::Params::Request do
  let(:instance) { described_class.new(method, uri, headers, body) }
  let(:method) { :get }
  let(:uri) { URI.parse 'https://example.com/path/to/resource?key=value' }
  let(:headers) { { 'Content-Type': 'application/json; charset=utf-8' } }
  let(:body) { nil }

  describe '#to_sawyer_args' do
    it 'returns value formatted for arguments of Sawyer::Agent#call' do
      expect(instance.to_sawyer_args).to eq [
        :get,
        'https://example.com/path/to/resource?key=value',
        nil,
        { headers: { 'Content-Type': 'application/json; charset=utf-8' } },
      ]
    end
  end

  describe '#metadata' do
    context 'when body parameter is blank' do
      it 'returns hashed parameters which omitted body parameter' do
        expect(instance.metadata).to eq(
          line: 'GET https://example.com/path/to/resource?key=value',
          headers: { 'Content-Type': 'application/json; charset=utf-8' }
        )
      end
    end

    context 'when query parameter is blank' do
      let(:method) { :post }
      let(:uri) { URI.parse 'https://example.com/path/to/resource' }
      let(:body) { { username: 'John Smith' } }

      it 'returns hashed parameters which omitted query parameter' do
        expect(instance.metadata).to eq(
          line: 'POST https://example.com/path/to/resource',
          headers: { 'Content-Type': 'application/json; charset=utf-8' },
          body: { username: 'John Smith' }
        )
      end
    end
  end

  describe '#inspect' do
    it 'returns contents as string for to be readable for human' do
      expect(instance.inspect)
        .to eq '{:method=>:get, ' \
               ':uri=>"https://example.com/path/to/resource?key=value", ' \
               ':headers=>{:"Content-Type"=>"application/json; charset=utf-8"}, ' \
               ':body=>nil}'
    end
  end
end
