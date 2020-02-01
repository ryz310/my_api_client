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
      subject(:execute) do
        instance.public_send(http_method, pathname, headers: headers, query: query, body: body)
      end

      before { allow(instance).to receive(:_request).and_return(response) }

      let(:pathname) { 'path/to/resource' }
      let(:headers) { { 'Content-Type': 'application/json;charset=UTF-8' } }
      let(:query) { { key: 'value' } }
      let(:body) { nil }
      let(:response) { instance_double(Sawyer::Response, data: resource) }
      let(:resource) { instance_double(Sawyer::Resource) }

      it 'calls #_request method and then processes the response' do
        execute
        expect(instance)
          .to have_received(:_request)
          .with(http_method, pathname, headers, query, body, instance_of(self.class::MyLogger))
          .ordered
        expect(response)
          .to have_received(:data)
          .with(no_args)
          .ordered
      end

      it { is_expected.to eq resource }
    end
  end
end
