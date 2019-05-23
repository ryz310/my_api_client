# frozen_string_literal: true

RSpec.describe MyApiClient::ErrorHandling do
  class MockClass
    include MyApiClient::ErrorHandling
    class_attribute :error_handlers, default: []

    error_handling status_code: /40[0-3]/, with: :client_error
    error_handling status_code: 404, with: :not_found
    error_handling status_code: 500..999 do
      puts 'Status code is detected which over 500'
    end
    #
    # error_handling json: { '$.errors.code': 404 }, with: :not_found
    # error_handling json: { '$.errors.code': 500..999 } do
    #   puts 'Status code is detected which over 500'
    # end
  end

  let(:instance) { MockClass.new }
  let(:error_handler) do
    instance.error_handlers.each do |error_handler|
      result = error_handler.call(response)
      return result unless result.nil?
    end
  end
  let(:response) do
    Sawyer::Response.new(
      instance_double(
        Sawyer::Agent, decode_body: response_body, parse_links: []
      ),
      instance_double(
        Faraday::Response,
        status: status_code,
        headers: { content_type: 'application/json; charset=utf-8' },
        env: nil,
        body: response_body.to_json
      )
    )
  end

  describe '.error_handling' do
    describe 'use `status_code`' do
      describe 'with Regexp' do
        let(:status_code) { 401 }
        let(:response_body) { nil }

        it 'detects that given status code is matched with the pattern' do
          expect(error_handler).to eq :client_error
        end
      end

      describe 'with Integer' do
        let(:status_code) { 404 }
        let(:response_body) { nil }

        it 'detects that given status code is equal' do
          expect(error_handler).to eq :not_found
        end
      end

      describe 'with Range' do
        let(:status_code) { 504 }
        let(:response_body) { nil }

        it 'detects that given status code is included within handling range' do
          expect(error_handler)
            .to output("Status code is detected which over 500\n")
            .to_stdout
        end
      end
    end
  end
end
