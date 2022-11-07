# frozen_string_literal: true

RSpec.describe MyApiClient::Base do
  let(:my_logger_class) do
    Class.new(::Logger) do
      def initialize
        super($stdout)
      end
    end
  end

  let(:mock_class) do
    stub_const 'MyLoggerClass', my_logger_class

    Class.new(described_class) do
      self.logger = MyLoggerClass.new
    end
  end

  let(:instance) { mock_class.new }

  describe '.logger=' do
    it 'overrides the log output destination' do
      expect(instance.logger).to be_a MyLoggerClass
    end
  end
end
