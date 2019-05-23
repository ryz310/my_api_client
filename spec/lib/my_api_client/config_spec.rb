# frozen_string_literal: true

RSpec.describe MyApiClient::Config do
  class MockClass
    include MyApiClient::Config
  end
  let(:instance) { MockClass.new }

  described_class::CONFIG_METHODS.each do |config_method|
    describe "##{config_method}" do
      before { MockClass.public_send(config_method, 'value') }

      it 'returns a value which set from the class method' do
        expect(instance.public_send(config_method)).to eq 'value'
      end
    end
  end
end
