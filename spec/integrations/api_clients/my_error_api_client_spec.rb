# frozen_string_literal: true

require './example/api_clients/my_error_api_client'
require 'my_api_client/rspec'

RSpec.describe 'Integration test with My Error API', type: :integration do
  describe 'GET error/:code' do
    shared_examples 'the API client' do
      context 'with error code: 0' do
        it do
          expect { api_client.get_error(code: 0) }
            .to raise_error(MyErrors::ErrorCode00)
        end
      end

      context 'with error code: 10' do
        it do
          expect { api_client.get_error(code: 10) }
            .to raise_error(MyErrors::ErrorCode10)
        end
      end

      context 'with error code: 20 to 29' do
        it do
          expect { api_client.get_error(code: rand(20..29)) }
            .to raise_error(MyErrors::ErrorCode2x)
        end
      end

      context 'with error code: 30' do
        it do
          expect { api_client.get_error(code: 30) }
            .to raise_error(MyErrors::ErrorCode30)
        end
      end

      context 'with error code: other' do
        it do
          expect { api_client.get_error(code: 40) }
            .to raise_error(MyErrors::ErrorCodeOther)
        end
      end
    end

    context 'with real connection' do
      let(:api_client) { MyErrorApiClient.new }

      it_behaves_like 'the API client'
    end

    context 'with stubbed API client' do
      let(:api_client) { stub_api_client(MyErrorApiClient, get_error: get_error) }

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
