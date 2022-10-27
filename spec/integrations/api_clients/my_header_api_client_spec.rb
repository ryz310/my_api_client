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

      xcontext 'when the first header is invalid' do
        let(:first_header_value) { 'this is invalid header value' }
        let(:second_header_value) { nil }
        it do 
          expect { api_request }
            .to raise_error(MyErrors::FirstHeaderIsInvalid)
        end
      end

      xcontext 'when the first header is zero' do
        let(:first_header_value) { 0 }
        let(:second_header_value) { nil }
        it do 
          binding.pry
          expect { api_request }
            .to raise_error(MyErrors::FirstHeaderIs00)
        end
      end

      context 'when the first header is in 1xx' do
        let(:first_header_value) { rand(100..199) }
        let(:second_header_value) { nil }
        it do
          expect { api_request }
            .to raise_error(MyErrors::FirstHeaderIs1xx)
        end
      end

    end

    context 'with real connection' do
      let(:api_client) { MyHeaderApiClient.new }

      it_behaves_like 'the API client'
    end

    xcontext 'with stubbed API client' do
      let(:api_client) { stub_api_client(MyHeaderApiClient, get_error: get_error) }

      let(:get_error) do
        lambda do |params|
          exception =
            case params[:code]
            when 0      then MyErrors::ErrorCode00
            when 10     then MyErrors::ErrorCode10
            when 20..29 then MyErrors::ErrorCode2x
            when 30     then MyErrors::ErrorCode30
            else;            MyErrors::ErrorCodeOther
            end
          raise exception
        end
      end

      it_behaves_like 'the API client'
    end
  end
end
