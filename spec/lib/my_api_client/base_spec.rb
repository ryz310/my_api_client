# frozen_string_literal: true

RSpec.describe MyApiClient::Base do
  class self::MyLogger < ::Logger
    def initialize
      super(STDOUT)
    end
  end

  class self::MockClass < described_class
    self.logger = RSpec::ExampleGroups::MyApiClientBase::MyLogger.new
  end

  let(:instance) { self.class::MockClass.new }

  describe '.logger=' do
    it 'overrides the log output destination' do
      expect(instance.logger).to be_kind_of(self.class::MyLogger)
    end
  end
end
