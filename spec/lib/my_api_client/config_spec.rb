# frozen_string_literal: true

RSpec.describe MyApiClient::Config do
  class self::SuperMockClass
    include MyApiClient::Config

    endpoint 'https://super_mock_class.com'
  end

  class self::MockClass < self::SuperMockClass
    endpoint 'https://mock_class.com'
  end

  class self::AnotherMockClass < self::SuperMockClass
  end

  let(:instance) { self.class::MockClass.new }

  describe 'overriding and inheritance' do
    let(:super_instance) { self.class::SuperMockClass.new }
    let(:another_instance) { self.class::AnotherMockClass.new }

    it 'can override superclass\' configuration' do
      expect(super_instance.endpoint).to eq 'https://super_mock_class.com'
      expect(instance.endpoint).to eq 'https://mock_class.com'
    end

    it 'can inherit superclass\' configuration' do
      expect(super_instance.endpoint).to eq 'https://super_mock_class.com'
      expect(another_instance.endpoint).to eq 'https://super_mock_class.com'
    end
  end

  described_class::CONFIG_METHODS.each do |config_method|
    describe "##{config_method}" do
      before { self.class::MockClass.public_send(config_method, "#{config_method}_value") }

      it 'returns a value which set from the class method' do
        expect(instance.public_send(config_method)).to eq "#{config_method}_value"
      end
    end
  end
end
