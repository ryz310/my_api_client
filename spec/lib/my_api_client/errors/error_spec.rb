# frozen_string_literal: true

RSpec.describe MyApiClient::Error do
  let(:instance) { described_class.new(params) }
  let(:params) do
    instance_double(
      MyApiClient::Params::Params, inspect: '"#<MyApiClient::Params::Params#inspect>"'
    )
  end

  describe '#params' do
    it 'returns a params instance' do
      expect(instance.params).to eq params
    end
  end

  describe '#to_bugsnag' do
    it 'delegates processing to params#to_bugsnag' do
      allow(params).to receive(:to_bugsnag)
      instance.to_bugsnag
      expect(params).to have_received(:to_bugsnag)
    end
  end

  describe '#inspect' do
    it 'returns contents as string for to be readable for human' do
      expect(instance.inspect)
        .to eq '{:error=>"#<MyApiClient::Error: MyApiClient::Error>", ' \
               ':params=>"#<MyApiClient::Params::Params#inspect>"}'
    end
  end
end
