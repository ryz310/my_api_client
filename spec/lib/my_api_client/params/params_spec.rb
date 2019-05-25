# frozen_string_literal: true

RSpec.describe MyApiClient::Params::Params do
  let(:instance) { described_class.new(request, response) }

  describe '#inspect' do
    let(:request) do
      instance_double(
        MyApiClient::Params::Request,
        inspect: '"#<MyApiClient::Params::Request#inspect>"'
      )
    end
    let(:response) do
      instance_double(
        Sawyer::Response,
        inspect: '"#<Sawyer::Response#inspect>"'
      )
    end

    it 'returns contents as string for to be readable for human' do
      expect(instance.inspect)
        .to eq '{:request=>"#<MyApiClient::Params::Request#inspect>", ' \
               ':response=>"#<Sawyer::Response#inspect>"}'
    end
  end
end
