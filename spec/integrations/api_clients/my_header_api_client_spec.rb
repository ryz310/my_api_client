# frozen_string_literal: true

require './example/api_clients/my_header_api_client'
require 'my_api_client/rspec'

RSpec.describe 'Integration test with My Header API', type: :integration do
  describe 'GET header' do
    shared_examples 'the API client' do
      subject(:api_request) do
        api_client.get_header(
          first_header: first_header_value,
          second_header: second_header_value
        )
      end

      context 'when the first header contains invalid' do
        let(:first_header_value) { 'this is invalid header value' }
        let(:second_header_value) { nil }

        it do
          expect { api_request }
            .to raise_error(MyErrors::FirstHeaderIsInvalid)
        end
      end

      context 'when the first header contains unknown and the second header contains error' do
        let(:first_header_value) { 'this header value is unknown' }
        let(:second_header_value) { 'error has occurred' }

        it do
          expect { api_request }
            .to raise_error(MyErrors::MultipleHeaderIsInvalid)
        end
      end
    end

    context 'with real connection' do
      let(:api_client) { MyHeaderApiClient.new }

      it_behaves_like 'the API client'
    end

    context 'with stubbed API client' do
      let(:api_client) { stub_api_client(MyHeaderApiClient, get_header: get_header) }

      let(:get_header) do
        lambda do |params|
          if params[:first_header].include?('unknown') &&
             params[:second_header].include?('error')
            raise MyErrors::MultipleHeaderIsInvalid
          elsif params[:first_header].include?('invalid')
            raise MyErrors::FirstHeaderIsInvalid
          end
        end
      end

      it_behaves_like 'the API client'
    end
  end
end
