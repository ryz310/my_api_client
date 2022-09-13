# frozen_string_literal: true

require 'my_api_client/rspec/matcher_helper'

RSpec.describe MyApiClient::ErrorHandling::RetryOptionProcessor do
  describe '.call' do
    subject(:execute) do
      described_class.call(error_handling_options: error_handling_options)
    end

    let(:error_handling_options) do
      retry_option.merge raise_option.merge block_option
    end

    let(:retry_option) { {} }
    let(:raise_option) { { raise: MyApiClient::Error } }
    let(:block_option) { {} }

    shared_examples 'requires `raise` option' do
      context 'without `raise` option' do
        let(:raise_option) { {} }

        it { expect { execute }.to raise_error(/The `retry` option requires `raise` option/) }
      end
    end

    shared_examples 'forbid `block` option' do
      context 'with `block` option' do
        let(:block_option) { { block: -> {} } }

        it { expect { execute }.to raise_error(/The `block` option is forbidden/) }
      end
    end

    describe 'error_handling_options' do
      context 'with `retry: true` option' do
        let(:retry_option) { { retry: true } }

        it { is_expected.to be_a(Hash).and be_blank }
        it { expect { execute }.to change { error_handling_options[:retry] }.to(nil) }

        it_behaves_like 'requires `raise` option'
        it_behaves_like 'forbid `block` option'
      end

      context 'with `retry: { wait: 1.minute, attempts: 2 }` option' do
        let(:retry_option) { { retry: { wait: 1.minute, attempts: 2 } } }

        it { is_expected.to eq(wait: 1.minute, attempts: 2) }
        it { expect { execute }.to change { error_handling_options[:retry] }.to(nil) }

        it_behaves_like 'requires `raise` option'
        it_behaves_like 'forbid `block` option'
      end

      context 'without `retry` option' do
        it { is_expected.to be_nil }
      end
    end
  end
end
