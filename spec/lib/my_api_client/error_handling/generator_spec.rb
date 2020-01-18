# frozen_string_literal: true

require 'my_api_client/rspec/matcher_helper'

RSpec.describe MyApiClient::ErrorHandling::Generator do
  include MyApiClient::MatcherHelper

  subject(:execute) { described_class.call(**options) }

  let(:options) do
    response_option.merge matcher_options.merge error_handling_options
  end

  let(:response_option) do
    { response: http_response }
  end

  shared_examples 'hoge' do
    describe 'error handling options' do
      context 'with `raise` option' do
        let(:error_handling_options) do
          { raise: MyApiClient::ClientError }
        end

        it { is_expected.to be_kind_of Proc }
      end

      context 'with `blcok` option' do
        let(:error_handling_options) do
          { block: -> {} }
        end

        it { is_expected.to be_kind_of Proc }
      end

      context 'with `with` option' do
        let(:error_handling_options) do
          { with: :my_error_handling }
        end

        it { is_expected.to eq :my_error_handling }
      end
    end
  end

  shared_examples 'fuga' do
    describe 'error handling options' do
      context 'with `raise` option' do
        let(:error_handling_options) do
          { raise: MyApiClient::ClientError }
        end

        it { is_expected.to be_nil }
      end

      context 'with `blcok` option' do
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
    context 'with `status_code` option' do
      let(:matcher_options) do
        { status_code: 400 }
      end

      context 'when matcher options matche the HTTP response' do
        let(:http_response) { dummy_response(status: 400) }

        it_behaves_like 'hoge'
      end

      context 'when matcher options matche the HTTP response' do
        let(:http_response) { dummy_response(status: 500) }

        it_behaves_like 'fuga'
      end
    end

    context 'with `json` option' do
      let(:http_response) { dummy_response(body: response_body) }

      context 'with integer' do
        let(:matcher_options) do
          { json: { '$.errors.code': 10 } }
        end

        context 'when matcher options matche the HTTP response' do
          let(:response_body) { { errors: { code: 10 } }.to_json }

          it_behaves_like 'hoge'
        end

        context 'when matcher options matche the HTTP response' do
          let(:response_body) { { errors: { code: 20 } }.to_json }

          it_behaves_like 'fuga'
        end
      end

      context 'with string' do
        let(:matcher_options) do
          { json: { '$.errors.message': 'error' } }
        end

        context 'when matcher options matche the HTTP response' do
          let(:response_body) { { errors: { message: 'error' } }.to_json }

          it_behaves_like 'hoge'
        end

        context 'when matcher options matche the HTTP response' do
          let(:response_body) { { errors: { message: 'warning' } }.to_json }

          it_behaves_like 'fuga'
        end
      end

      context 'with boolean' do
        let(:matcher_options) do
          { json: { '$.errors.is_transient': true } }
        end

        context 'when matcher options matche the HTTP response' do
          let(:response_body) { { errors: { is_transient: true } }.to_json }

          it_behaves_like 'hoge'
        end

        context 'when matcher options matche the HTTP response' do
          let(:response_body) { { errors: { is_transient: false } }.to_json }

          it_behaves_like 'fuga'
        end
      end

      context 'with range' do
        let(:matcher_options) do
          { json: { '$.errors.code': 10..20 } }
        end

        context 'when matcher options matche the HTTP response' do
          let(:response_body) { { errors: { code: 15 } }.to_json }

          it_behaves_like 'hoge'
        end

        context 'when matcher options matche the HTTP response' do
          let(:response_body) { { errors: { code: 21 } }.to_json }

          it_behaves_like 'fuga'
        end
      end

      context 'with regexp' do
        let(:matcher_options) do
          { json: { '$.errors.message': /error/ } }
        end

        context 'when matcher options matche the HTTP response' do
          let(:response_body) { { errors: { message: 'some error occurred' } }.to_json }

          it_behaves_like 'hoge'
        end

        context 'when matcher options matche the HTTP response' do
          let(:response_body) { { errors: { message: 'some warning occurred' } }.to_json }

          it_behaves_like 'fuga'
        end
      end

      context 'with symbol' do
        let(:matcher_options) do
          { json: { '$.errors.code': :negative? } }
        end

        context 'when matcher options matche the HTTP response' do
          let(:response_body) { { errors: { code: -1 } }.to_json }

          it_behaves_like 'hoge'
        end

        context 'when matcher options matche the HTTP response' do
          let(:response_body) { { errors: { code: 0 } }.to_json }

          it_behaves_like 'fuga'
        end
      end

      context 'with :forbid_nil' do
        let(:matcher_options) do
          { json: :forbid_nil }
        end

        context 'when matcher options matche the HTTP response' do
          let(:response_body) { nil }

          it_behaves_like 'hoge'
        end

        context 'when matcher options matche the HTTP response' do
          let(:response_body) { '' }

          it_behaves_like 'fuga'
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
  end
end
