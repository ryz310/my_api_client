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

  described_class::HTTP_METHODS.each do |http_method|
    describe "##{http_method}" do
      before { allow(instance).to receive(:_request) }

      let(:pathname) { 'path/to/resource' }
      let(:headers) { { 'Content-Type': 'application/json;charset=UTF-8' } }
      let(:query) { { key: 'value' } }
      let(:body) { nil }

      it do
        instance.public_send(http_method, pathname, headers: headers, query: query, body: body)
        expect(instance)
          .to have_received(:_request)
          .with(http_method, pathname, headers, query, body, instance_of(self.class::MyLogger))
      end
    end
  end
end
