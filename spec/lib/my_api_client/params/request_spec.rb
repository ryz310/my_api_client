# frozen_string_literal: true

RSpec.describe MyApiClient::Params::Request do
  let(:instance) { described_class.new(method, pathname, headers, query, body) }
  let(:method) { 'GET' }
  let(:pathname) { 'path/to/resource' }
  let(:headers) { { 'Content-Type': 'application/json; charset=utf-8' } }
  let(:query) { { key: 'value' } }
  let(:body) { nil }

  describe '#to_sawyer_args' do
    subject { instance.to_sawyer_args }

    it 'returns value formatted for arguments of Sawyer::Agent#call' do
      expect(instance.to_sawyer_args).to eq [
        'GET',
        'path/to/resource',
        nil,
        {
          headers: { 'Content-Type': 'application/json; charset=utf-8' },
          query: { key: 'value' },
        },
      ]
    end
  end

  describe '#inspect' do
    it 'returns contents as string for to be readable for human' do
      expect(instance.inspect)
        .to eq '{:method=>"GET", ' \
               ':pathname=>"path/to/resource", ' \
               ':headers=>{:"Content-Type"=>"application/json; charset=utf-8"}, ' \
               ':query=>{:key=>"value"}, :body=>nil}'
    end
  end
end
