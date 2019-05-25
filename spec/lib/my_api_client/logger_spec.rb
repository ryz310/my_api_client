# frozen_string_literal: true

RSpec.describe MyApiClient::Logger do
  let(:instance) { described_class.new(logger, faraday, method, url) }
  let(:logger) { instance_double(::Logger, logging_methods) }
  let(:logging_methods) { MyApiClient::Logger::LOG_LEVEL.zip([]).to_h }
  let(:faraday) { instance_double(Faraday::Connection, build_exclusive_url: endpoint) }
  let(:endpoint) { "https://example.com/#{url}" }
  let(:method) { :get }
  let(:url) { 'path/to/resouce' }

  MyApiClient::Logger::LOG_LEVEL.each do |log_level|
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
