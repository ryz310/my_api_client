# frozen_string_literal: true

RSpec.describe MyApiClient::NetworkError do
  let(:ruby34_or_later) { Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('3.4') }

  context 'when initialized with params and original error' do
    let(:instance) { described_class.new(params, network_error) }
    let(:expected_inspect) do
      if ruby34_or_later
        [
          '{error: "#<Net::OpenTimeout>", ',
          'params: "#<MyApiClient::Params::Params#inspect>"}',
        ].join
      else
        [
          '{:error=>"#<Net::OpenTimeout>", ',
          ':params=>"#<MyApiClient::Params::Params#inspect>"}',
        ].join
      end
    end
    let(:params) do
      instance_double(
        MyApiClient::Params::Params,
        inspect: '"#<MyApiClient::Params::Params#inspect>"',
        metadata: { params: 'original metadata' }
      )
    end
    let(:network_error) do
      instance_double(
        Net::OpenTimeout, message: 'Net::OpenTimeout', inspect: '"#<Net::OpenTimeout>"'
      )
    end

    describe '#original_error' do
      it 'returns an original error instance' do
        expect(instance.original_error).to eq network_error
      end
    end

    describe '#params' do
      it 'returns a params instance' do
        expect(instance.params).to eq params
      end
    end

    describe '#inspect' do
      it { expect(instance.inspect).to eq expected_inspect }
    end

    describe '#metadata' do
      it 'overrides super class #metadata to add original error information' do
        expect(instance.metadata)
          .to eq(params: 'original metadata', original_error: network_error.inspect)
      end
    end
  end

  context 'when initialized with no arguments (for RSpec)' do
    let(:instance) { described_class.new }
    let(:expected_inspect) do
      ruby34_or_later ? '{error: nil, params: nil}' : '{:error=>nil, :params=>nil}'
    end

    describe '#original_error' do
      it { expect(instance.original_error).to be_nil }
    end

    describe '#params' do
      it { expect(instance.params).to be_nil }
    end

    describe '#inspect' do
      it { expect(instance.inspect).to eq expected_inspect }
    end

    describe '#metadata' do
      it { expect(instance.metadata).to be_nil }
    end
  end
end
