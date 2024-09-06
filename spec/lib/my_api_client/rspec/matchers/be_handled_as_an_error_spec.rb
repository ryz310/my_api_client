# frozen_string_literal: true

require 'my_api_client/rspec'

RSpec.describe 'be_handled_as_an_error' do
  let(:api_client_class) do
    Class.new(MyApiClient::Base) do
      endpoint 'https://example.com'

      error_handling json: { '$.errors.code': 10 },
                     raise: MyApiClient::ApiLimitError,
                     retry: { wait: 10.seconds, attempts: 2 }

      attr_reader :access_token

      def initialize(access_token:)
        @access_token = access_token
      end

      def get_users
        get 'users', headers:
      end

      private

      def headers
        {
          'Content-Type': 'application/json;charset=UTF-8',
          Authorization: "Bearer #{access_token}",
        }
      end
    end
  end

  let(:api_client) { api_client_class.new(access_token: 'access_token') }
  let(:response_body) { { errors: { code: 10 } }.to_json }

  it 'avoids sleep on testing' do
    expect do
      expect { api_client.get_users }
        .to be_handled_as_an_error(MyApiClient::ApiLimitError)
        .after_retry(2).times
        .when_receive(body: response_body)
    end.to complete_within(0.1).second
  end
end
