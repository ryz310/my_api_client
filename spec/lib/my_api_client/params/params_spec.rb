# frozen_string_literal: true

RSpec.describe MyApiClient::Params::Params do
  let(:instance) { described_class.new(request, response) }

  let(:request) do
    instance_double(
      MyApiClient::Params::Request,
      inspect: '"#<MyApiClient::Params::Request#inspect>"',
      metadata: {
        line: 'GET path/to/resource',
        headers: { 'Content-Type': 'application/json; charset=utf-8' },
        query: { key: 'value' },
      }
    )
  end
  let(:response) do
    instance_double(
      Sawyer::Response,
      inspect: '"#<Sawyer::Response#inspect>"',
      status: 200,
      headers: { 'Content-Type': 'application/json; charset=utf-8' },
      data: { status: 'OK' },
      timing: 0.12345
    )
  end

  describe '#metadata' do
    context 'when given both params of request and response' do
      it 'returns metadata which integrated request and response params' do
        expect(instance.metadata).to eq(
          request_line: 'GET path/to/resource',
          request_headers: { 'Content-Type': 'application/json; charset=utf-8' },
          request_query: { key: 'value' },
          response_status: 200,
          response_headers: { 'Content-Type': 'application/json; charset=utf-8' },
          response_body: { status: 'OK' },
          duration: 0.12345
        )
      end
    end

    context 'when given only request params' do
      let(:response) { nil }

      it 'returns metadata just including request params' do
        expect(instance.metadata).to eq(
          request_line: 'GET path/to/resource',
          request_headers: { 'Content-Type': 'application/json; charset=utf-8' },
          request_query: { key: 'value' }
        )
      end
    end

    context 'when given only response params' do
      let(:request) { nil }

      it 'returns metadata just including response params' do
        expect(instance.metadata).to eq(
          response_status: 200,
          response_headers: { 'Content-Type': 'application/json; charset=utf-8' },
          response_body: { status: 'OK' },
          duration: 0.12345
        )
      end
    end
  end

  describe '#inspect' do
    it 'returns contents as string for to be readable for human' do
      expect(instance.inspect)
        .to eq '{:request=>"#<MyApiClient::Params::Request#inspect>", ' \
               ':response=>"#<Sawyer::Response#inspect>"}'
    end
  end
end
