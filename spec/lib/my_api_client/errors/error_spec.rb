# frozen_string_literal: true

RSpec.describe MyApiClient::Error do
  let(:instance) { described_class.new(params) }
  let(:params) do
    instance_double(
      MyApiClient::Params::Params,
      inspect: '"#<MyApiClient::Params::Params#inspect>"',
      metadata: { request: 'params', response: 'params' }
    )
  end

  describe '#params' do
    it 'returns a params instance' do
      expect(instance.params).to eq params
    end
  end

  describe '#metadata' do
    it 'delegates processing to params#metadata' do
      expect(instance.metadata).to eq(request: 'params', response: 'params')
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
