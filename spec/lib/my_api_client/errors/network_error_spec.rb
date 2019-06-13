# frozen_string_literal: true

RSpec.describe MyApiClient::NetworkError do
  let(:instance) { described_class.new(params, network_error) }
  let(:params) do
    instance_double(
      MyApiClient::Params::Params,
      inspect: '"#<MyApiClient::Params::Params#inspect>"',
      metadata: { params: 'original metadata' }
    )
  end
  let(:network_error) do
    instance_double(
      Net::OpenTimeout, message: 'Net::OpenTimeout', inspect: '"#<Net::OpenTimeout>"'
    )
  end

  describe '#original_error' do
    it 'returns an original error instance' do
      expect(instance.original_error).to eq network_error
    end
  end

  describe '#params' do
    it 'returns a params instance' do
      expect(instance.params).to eq params
    end
  end

  describe '#inspect' do
    it 'returns contents as string for to be readable for human' do
      expect(instance.inspect)
        .to eq '{:error=>"#<Net::OpenTimeout>", ' \
               ':params=>"#<MyApiClient::Params::Params#inspect>"}'
    end
  end

  describe '#metadata' do
    it 'overrides super class #metadata to add original error information' do
      expect(instance.metadata)
        .to eq(params: 'original metadata', original_error: network_error.inspect)
    end
  end
end
