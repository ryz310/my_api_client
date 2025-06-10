# frozen_string_literal: true

RSpec.describe MyApiClient::Base do
  let(:my_logger_class) do
    Class.new(Logger) do
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

  describe '#logger=' do
    let(:new_logger) { Logger.new($stdout) }

    it 'overrides the log output destination' do
      expect(instance.logger).not_to eq(new_logger)
      instance.logger = new_logger
      expect(instance.logger).to eq(new_logger)
    end
  end
end
