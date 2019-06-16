# frozen_string_literal: true

if defined?(Bugsnag)
  RSpec.describe MyApiClient::Error do
    describe '#initialize' do
      let(:params) { instance_double(MyApiClient::Params::Params, metadata: metadata) }
      let(:metadata) { { metadata: 'metadata' } }

      it 'calls Bugsnag.leave_breadcrumb with #metadata' do
        allow(Bugsnag).to receive(:leave_breadcrumb)
        described_class.new(params, 'error message')
        expect(Bugsnag).to have_received(:leave_breadcrumb).with(
          'MyApiClient::Error occurred',
          metadata,
          Bugsnag::Breadcrumbs::ERROR_BREADCRUMB_TYPE
        )
      end
    end
  end
end
