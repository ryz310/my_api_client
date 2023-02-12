# frozen_string_literal: true

RSpec.describe MyApiClient::Request::Logger do
  let(:instance) { described_class.new(logger, method, uri) }
  let(:logger) { instance_double(Logger, logging_methods) }
  let(:logging_methods) { described_class::LOG_LEVEL.zip([]).to_h }
  let(:uri) { URI.parse('https://example.com/path/to/resouce') }
  let(:method) { :get }

  described_class::LOG_LEVEL.each do |log_level|
    describe "##{log_level}" do
      it "outputs message to the logger as `#{log_level}`, with the request information" do
        instance.public_send(log_level, 'message')
        expect(logger)
          .to have_received(log_level)
          .with('API request `GET https://example.com/path/to/resouce`: "message"')
      end
    end
  end
end
