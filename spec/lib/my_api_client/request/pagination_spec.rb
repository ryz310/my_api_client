# frozen_string_literal: true

require 'my_api_client/rspec/stub'

RSpec.describe MyApiClient::Request::Pagination do
  include MyApiClient::Stub

  describe '#pageable_get' do
    let(:mock_class) do
      Class.new do
        include MyApiClient::Request::Pagination
        include MyApiClient::Exceptions

        def _request_with_relative_uri(http_method, pathname, headers, query, body); end

        def _request_with_absolute_uri(http_method, uri, headers, body); end
      end
    end

    let(:instance) { mock_class.new }
    let(:headers) { { 'Content-Type': 'application/json;charset=UTF-8' } }
    let(:query) { { key: 'value' } }

    let(:first_response) do
      stub_as_response(
        {
          page: 1,
          next: 'https://example.com/pages/2',
        },
        200
      )
    end

    let(:second_response) do
      stub_as_response(
        {
          page: 2,
          next: 'https://example.com/pages/3',
        },
        200
      )
    end

    let(:third_response) do
      stub_as_response(
        {
          page: 3,
        },
        200
      )
    end

    before do
      allow(instance).to receive(:_request_with_relative_uri)
        .and_return(first_response)
      allow(instance).to receive(:_request_with_absolute_uri)
        .and_return(second_response, third_response)
    end

    describe 'paging with JSONPath' do
      subject(:pageable_get) do
        instance.pageable_get(
          'pages/1', headers: headers, query: query, paging: '$.next'
        )
      end

      it { is_expected.to be_a Enumerator::Lazy }

      it 'executes HTTP requests sequentially to the pagination links' do
        pageable_get.to_a
        expect(instance).to have_received(:_request_with_relative_uri)
          .with(:get, 'pages/1', headers, query, nil).ordered
        expect(instance).to have_received(:_request_with_absolute_uri)
          .with(:get, 'https://example.com/pages/2', headers, nil).ordered
        expect(instance).to have_received(:_request_with_absolute_uri)
          .with(:get, 'https://example.com/pages/3', headers, nil).ordered
      end

      it 'yields the pagination API response' do
        expect { |b| pageable_get.each(&b) }.to yield_successive_args(
          first_response.data,
          second_response.data,
          third_response.data
        )
      end
    end

    describe 'paging with Proc' do
      subject(:pageable_get) do
        instance.pageable_get(
          'pages/1', headers: headers, query: query, paging: ->(response) { response.data.next }
        )
      end

      it { is_expected.to be_a Enumerator::Lazy }

      it 'executes HTTP requests sequentially to the pagination links' do
        pageable_get.to_a
        expect(instance).to have_received(:_request_with_relative_uri)
          .with(:get, 'pages/1', headers, query, nil).ordered
        expect(instance).to have_received(:_request_with_absolute_uri)
          .with(:get, 'https://example.com/pages/2', headers, nil).ordered
        expect(instance).to have_received(:_request_with_absolute_uri)
          .with(:get, 'https://example.com/pages/3', headers, nil).ordered
      end

      it 'yields the pagination API response' do
        expect { |b| pageable_get.each(&b) }.to yield_successive_args(
          first_response.data,
          second_response.data,
          third_response.data
        )
      end
    end
  end
end
