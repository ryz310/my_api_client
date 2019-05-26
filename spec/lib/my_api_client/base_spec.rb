# frozen_string_literal: true

RSpec.describe MyApiClient::Base do
  let(:instance) { described_class.new }

  described_class::HTTP_METHODS.each do |http_method|
    describe "##{http_method}" do
      before { allow(instance).to receive(:request) }

      let(:pathname) { 'path/to/resource' }
      let(:headers) { { 'Content-Type': 'application/json;charset=UTF-8' } }
      let(:query) { { key: 'value' } }
      let(:body) { nil }

      it do
        instance.public_send(http_method, pathname, headers: headers, query: query, body: body)
        expect(instance)
          .to have_received(:request)
          .with(http_method, pathname, headers, query, body, instance_of(::Logger))
      end
    end
  end
end
