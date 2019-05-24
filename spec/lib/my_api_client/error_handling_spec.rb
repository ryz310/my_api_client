# frozen_string_literal: true

RSpec.describe MyApiClient::ErrorHandling do
  class SomeError < MyApiClient::Error; end

  class SuperMockClass
    include MyApiClient::ErrorHandling
    class_attribute :error_handlers, default: []

    error_handling status_code: 500..999 do
      puts 'Status code is detected which over 500'
    end
  end

  class MockClass < SuperMockClass
    error_handling status_code: /40[0-3]/, with: :client_error
    error_handling status_code: 404, with: :not_found

    error_handling json: { '$.errors.message': 'maintenance time' }, with: :maintenance_time
    error_handling json: { '$.errors.message': /[sS]orry/ }, with: :server_error
    error_handling json: { '$.errors.code': 10 }, raise: SomeError
    error_handling json: { '$.errors.code': 20..29 }
  end

  let(:instance) { MockClass.new }
  let(:error_handler) do
    instance.error_handlers.each do |error_handler|
      result = error_handler.call(response)
      return result unless result.nil?
    end
  end
  let(:response) do
    instance_double(
      Sawyer::Response, status: status_code, body: response_body.to_json
    )
  end

  describe '.error_handling' do
    describe 'use `status_code`' do
      let(:response_body) { nil }

      describe 'with Regexp' do
        let(:status_code) { 401 }

        it 'detects that given status code is matched with the pattern' do
          expect(error_handler).to eq :client_error
        end
      end

      describe 'with Integer' do
        let(:status_code) { 404 }

        it 'detects that given status code is equal' do
          expect(error_handler).to eq :not_found
        end
      end

      describe 'with Range' do
        let(:status_code) { 504 }

        it 'detects that given status code is included within handling range' do
          expect(error_handler)
            .to output("Status code is detected which over 500\n")
            .to_stdout
        end
      end
    end

    describe 'use `json`' do
      let(:status_code) { 200 }

      describe 'with String' do
        let(:response_body) do
          {
            errors: {
              code: 99,
              message: 'maintenance time'
            }
          }
        end

        it 'detects that given JSON is equal with message in the jsonpath' do
          expect(error_handler).to eq :maintenance_time
        end
      end

      describe 'with Regexp' do
        let(:response_body) do
          {
            errors: {
              code: 99,
              message: 'Sorry, something went wrong.'
            }
          }
        end

        it 'detects that given JSON is matched with pattern in the jsonpath' do
          expect(error_handler).to eq :server_error
        end
      end

      describe 'with Integer' do
        let(:response_body) do
          {
            errors: {
              code: 10,
              message: 'some error occurred.'
            }
          }
        end
        let(:params) { instance_double(MyApiClient::Error) }
        let(:logger) { instance_double(MyApiClient::Logger) }

        it 'detects that given JSON is equal with number in the jsonpath' do
          expect { error_handler.call(params, logger) }.to raise_error(SomeError)
        end
      end

      describe 'with Range' do
        let(:response_body) do
          {
            errors: {
              code: 23,
              message: 'other error occurred.'
            }
          }
        end
        let(:params) { instance_double(MyApiClient::Error) }
        let(:logger) { instance_double(MyApiClient::Logger) }

        it 'detects that given JSON is included within range in the jsonpath' do
          expect { error_handler.call(params, logger) }.to raise_error(MyApiClient::Error)
        end
      end
    end
  end
end
