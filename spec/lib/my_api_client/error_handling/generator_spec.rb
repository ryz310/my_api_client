# frozen_string_literal: true

require 'my_api_client/rspec/matcher_helper'

RSpec.describe MyApiClient::ErrorHandling::Generator do
  include MyApiClient::MatcherHelper

  subject(:execute) { described_class.call(**options) }

  let(:safe_execution) do
    execute.call(params, logger)
  rescue MyApiClient::Error
    nil
  end

  let(:options) do
    required_params.merge matcher_options.merge error_handling_options
  end

  let(:required_params) do
    { instance: instance, response: http_response }
  end

  let(:instance) { instance_double(api_client, my_error_handling: nil) }

  shared_examples 'an error was detected' do
    describe 'error handling options' do
      let(:params) { instance_double(MyApiClient::Params::Params, metadata: {}) }
      let(:logger) { instance_double(MyApiClient::Request::Logger) }

      shared_examples 'returns a Proc instance' do |error_class|
        it "raises #{error_class.name} when executed" do
          expect { execute.call(params, logger) }.to raise_error(error_class)
        end
      end

      context 'with `raise` option' do
        let(:error_handling_options) do
          { raise: MyApiClient::ClientError }
        end

        it_behaves_like 'returns a Proc instance', MyApiClient::ClientError

        context 'with `block` option' do
          let(:error_handling_options) do
            { raise: MyApiClient::ClientError, block: block }
          end

          let(:block) { instance_double(Proc, call: nil) }

          it_behaves_like 'returns a Proc instance', MyApiClient::ClientError do
            it 'calls the block when executed' do
              safe_execution
              expect(block).to have_received(:call).with(params, logger)
            end
          end
        end

        context 'with `with` option' do
          let(:error_handling_options) do
            { raise: MyApiClient::ClientError, with: :my_error_handling }
          end

          it_behaves_like 'returns a Proc instance', MyApiClient::ClientError do
            it 'calls the instance method when executed' do
              safe_execution
              expect(instance).to have_received(:my_error_handling).with(params, logger)
            end
          end
        end
      end

      context 'without `raise` option' do
        let(:error_handling_options) do
          {}
        end

        it_behaves_like 'returns a Proc instance', MyApiClient::Error

        context 'with `block` option' do
          let(:error_handling_options) do
            { block: block }
          end

          let(:block) { instance_double(Proc, call: nil) }

          it_behaves_like 'returns a Proc instance', MyApiClient::Error do
            it 'calls the block when executed' do
              safe_execution
              expect(block).to have_received(:call).with(params, logger)
            end
          end
        end

        context 'with `with` option' do
          let(:error_handling_options) do
            { with: :my_error_handling }
          end

          it_behaves_like 'returns a Proc instance', MyApiClient::Error do
            it 'calls the instance method when executed' do
              safe_execution
              expect(instance).to have_received(:my_error_handling).with(params, logger)
            end
          end
        end
      end
    end
  end

  shared_examples 'no errors were detected' do
    describe 'error handling options' do
      context 'with `raise` option' do
        let(:error_handling_options) do
          { raise: MyApiClient::ClientError }
        end

        it { is_expected.to be_nil }
      end

      context 'with `block` option' do
        let(:error_handling_options) do
          { block: -> {} }
        end

        it { is_expected.to be_nil }
      end

      context 'with `with` option' do
        let(:error_handling_options) do
          { with: :my_error_handling }
        end

        it { is_expected.to be_nil }
      end
    end
  end

  describe 'matcher options' do
    context 'with `status_code` and `json` options' do
      let(:matcher_options) do
        { status_code: 400, json: { '$.errors.code': 10 } }
      end

      context 'when matcher options exactly match the HTTP response' do
        let(:http_response) do
          dummy_response(status: 400, body: { errors: { code: 10 } }.to_json)
        end

        it_behaves_like 'an error was detected'
      end

      context 'when matcher options partially match the status code in the HTTP response' do
        let(:http_response) do
          dummy_response(status: 400, body: { errors: { code: 20 } }.to_json)
        end

        it_behaves_like 'no errors were detected'
      end

      context 'when matcher options partially match the body in the HTTP response' do
        let(:http_response) do
          dummy_response(status: 403, body: { errors: { code: 10 } }.to_json)
        end

        it_behaves_like 'no errors were detected'
      end

      context 'when matcher options does NOT match the HTTP response' do
        let(:http_response) do
          dummy_response(status: 404, body: { errors: { code: 30 } }.to_json)
        end

        it_behaves_like 'no errors were detected'
      end
    end

    context 'with `status_code` option' do
      let(:matcher_options) do
        { status_code: 400 }
      end

      context 'when matcher options match the HTTP response' do
        let(:http_response) { dummy_response(status: 400) }

        it_behaves_like 'an error was detected'
      end

      context 'when matcher options does NOT match the HTTP response' do
        let(:http_response) { dummy_response(status: 500) }

        it_behaves_like 'no errors were detected'
      end
    end

    context 'with `json` option' do
      let(:http_response) { dummy_response(body: response_body) }

      context 'with integer' do
        let(:matcher_options) do
          { json: { '$.errors.code': 10 } }
        end

        context 'when matcher options match the HTTP response' do
          let(:response_body) { { errors: { code: 10 } }.to_json }

          it_behaves_like 'an error was detected'
        end

        context 'when matcher options does NOT match the HTTP response' do
          let(:response_body) { { errors: { code: 20 } }.to_json }

          it_behaves_like 'no errors were detected'
        end
      end

      context 'with string' do
        let(:matcher_options) do
          { json: { '$.errors.message': 'error' } }
        end

        context 'when matcher options match the HTTP response' do
          let(:response_body) { { errors: { message: 'error' } }.to_json }

          it_behaves_like 'an error was detected'
        end

        context 'when matcher options does NOT match the HTTP response' do
          let(:response_body) { { errors: { message: 'warning' } }.to_json }

          it_behaves_like 'no errors were detected'
        end
      end

      context 'with boolean' do
        let(:matcher_options) do
          { json: { '$.errors.is_transient': true } }
        end

        context 'when matcher options match the HTTP response' do
          let(:response_body) { { errors: { is_transient: true } }.to_json }

          it_behaves_like 'an error was detected'
        end

        context 'when matcher options does NOT match the HTTP response' do
          let(:response_body) { { errors: { is_transient: false } }.to_json }

          it_behaves_like 'no errors were detected'
        end
      end

      context 'with range' do
        let(:matcher_options) do
          { json: { '$.errors.code': 10..20 } }
        end

        context 'when matcher options match the HTTP response' do
          let(:response_body) { { errors: { code: 15 } }.to_json }

          it_behaves_like 'an error was detected'
        end

        context 'when matcher options does NOT match the HTTP response' do
          let(:response_body) { { errors: { code: 21 } }.to_json }

          it_behaves_like 'no errors were detected'
        end
      end

      context 'with regexp' do
        let(:matcher_options) do
          { json: { '$.errors.message': /error/ } }
        end

        context 'when matcher options match the HTTP response' do
          let(:response_body) { { errors: { message: 'some error occurred' } }.to_json }

          it_behaves_like 'an error was detected'
        end

        context 'when matcher options does not match the HTTP response' do
          let(:response_body) { { errors: { message: 'some warning occurred' } }.to_json }

          it_behaves_like 'no errors were detected'
        end
      end

      context 'with symbol' do
        let(:matcher_options) do
          { json: { '$.errors.code': :negative? } }
        end

        context 'when matcher options match the HTTP response' do
          let(:response_body) { { errors: { code: -1 } }.to_json }

          it_behaves_like 'an error was detected'
        end

        context 'when matcher options does NOT match the HTTP response' do
          let(:response_body) { { errors: { code: 0 } }.to_json }

          it_behaves_like 'no errors were detected'
        end
      end

      context 'with :forbid_nil' do
        let(:matcher_options) do
          { json: :forbid_nil }
        end

        context 'when matcher options match the HTTP response' do
          let(:response_body) { nil }

          it_behaves_like 'an error was detected'
        end

        context 'when matcher options does NOT match the HTTP response' do
          let(:response_body) { '' }

          it_behaves_like 'no errors were detected'
        end
      end

      context 'with unexpected operator' do
        let(:matcher_options) do
          { json: { '$.errors.code': Object } }
        end

        let(:response_body) { { errors: { code: 10 } }.to_json }
        let(:error_handling_options) { { with: :my_error_handling } }

        it { expect { execute }.to raise_error(/Unexpected operator type was given/) }
      end
    end

    context 'with unexpected option' do
      let(:matcher_options) do
        { status: 400 } # It should be "status_code".
      end

      let(:http_response) { dummy_response(status: 400) }
      let(:error_handling_options) { { with: :my_error_handling } }

      it { expect { execute }.to raise_error(/Specified an incorrect option/) }
    end
  end
end
