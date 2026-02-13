# frozen_string_literal: true

if defined?(Bugsnag)
  RSpec.describe MyApiClient::Error do
    let(:ruby34_or_later) { Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('3.4') }

    describe '#initialize' do
      context 'with params and error message' do
        let(:params) { instance_double(MyApiClient::Params::Params, metadata:) }
        let(:metadata) { { a: 1, b: { c: 2, d: 3 } } }
        let(:expected_metadata) do
          ruby34_or_later ? { a: '1', b: '{c: 2, d: 3}' } : { a: '1', b: '{:c=>2, :d=>3}' }
        end

        it 'calls Bugsnag.leave_breadcrumb with metadata' do
          allow(Bugsnag).to receive(:leave_breadcrumb)
          described_class.new(params, 'error message')
          expect(Bugsnag).to have_received(:leave_breadcrumb).with(
            'MyApiClient::Error occurred',
            expected_metadata,
            Bugsnag::Breadcrumbs::ERROR_BREADCRUMB_TYPE
          )
        end
      end

      context 'with no arguments' do
        it 'calls Bugsnag.leave_breadcrumb without metadata' do
          allow(Bugsnag).to receive(:leave_breadcrumb)
          described_class.new
          expect(Bugsnag).to have_received(:leave_breadcrumb).with(
            'MyApiClient::Error occurred',
            nil,
            Bugsnag::Breadcrumbs::ERROR_BREADCRUMB_TYPE
          )
        end
      end
    end
  end
end
