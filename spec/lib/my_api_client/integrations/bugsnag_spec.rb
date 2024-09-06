# frozen_string_literal: true

if defined?(Bugsnag)
  RSpec.describe MyApiClient::Error do
    describe '#initialize' do
      context 'with params and error message' do
        let(:params) { instance_double(MyApiClient::Params::Params, metadata:) }
        let(:metadata) { { a: 1, b: { c: 2, d: 3 } } }

        it 'calls Bugsnag.leave_breadcrumb with metadata' do
          allow(Bugsnag).to receive(:leave_breadcrumb)
          described_class.new(params, 'error message')
          expect(Bugsnag).to have_received(:leave_breadcrumb).with(
            'MyApiClient::Error occurred',
            { a: '1', b: '{:c=>2, :d=>3}' },
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
