# frozen_string_literal: true

RSpec.describe MyApiClient::Error do
  let(:ruby34_or_later) { Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('3.4') }

  context 'when initialized with params and error message' do
    let(:instance) { described_class.new(params, 'error message') }
    let(:expected_inspect) do
      if ruby34_or_later
        [
          '{error: "#<MyApiClient::Error: error message>", ',
          'params: "#<MyApiClient::Params::Params#inspect>"}',
        ].join
      else
        [
          '{:error=>"#<MyApiClient::Error: error message>", ',
          ':params=>"#<MyApiClient::Params::Params#inspect>"}',
        ].join
      end
    end

    let(:params) do
      instance_double(
        MyApiClient::Params::Params,
        inspect: '"#<MyApiClient::Params::Params#inspect>"',
        metadata: { request: 'params', response: 'params' }
      )
    end

    describe '#params' do
      it 'returns a params instance' do
        expect(instance.params).to eq params
      end
    end

    describe '#metadata' do
      it 'delegates processing to params#metadata' do
        expect(instance.metadata).to eq(request: 'params', response: 'params')
      end
    end

    describe '#inspect' do
      it { expect(instance.inspect).to eq expected_inspect }
    end

    describe '#message' do
      it { expect(instance.message).to eq 'error message' }
    end
  end

  context 'when initialized with no arguments (for RSpec)' do
    let(:instance) { described_class.new }
    let(:expected_inspect) do
      if ruby34_or_later
        '{error: "#<MyApiClient::Error: MyApiClient::Error>", params: nil}'
      else
        '{:error=>"#<MyApiClient::Error: MyApiClient::Error>", :params=>nil}'
      end
    end

    describe '#params' do
      it { expect(instance.params).to be_nil }
    end

    describe '#metadata' do
      it { expect(instance.metadata).to be_nil }
    end

    describe '#inspect' do
      it { expect(instance.inspect).to eq expected_inspect }
    end

    describe '#message' do
      it { expect(instance.message).to eq 'MyApiClient::Error' }
    end
  end
end
