# frozen_string_literal: true

RSpec.describe MyApiClient::Config do
  let(:super_mock_class) do
    Class.new do
      include MyApiClient::Config
      endpoint 'https://super_mock_class.com'
    end
  end

  let(:mock_class) do
    Class.new(super_mock_class) do
      endpoint 'https://mock_class.com'
    end
  end

  let(:another_mock_class) do
    Class.new(super_mock_class)
  end

  let(:instance) { mock_class.new }

  describe 'overriding and inheritance' do
    let(:super_instance) { super_mock_class.new }
    let(:another_instance) { another_mock_class.new }

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
      before { mock_class.public_send(config_method, "#{config_method}_value") }

      it 'returns a value which set from the class method' do
        expect(instance.public_send(config_method)).to eq "#{config_method}_value"
      end
    end
  end
end
