# frozen_string_literal: true

require 'my_api_client/rspec'

RSpec.describe 'be_handled_as_an_error' do
  let(:api_client_class) do
    Class.new(MyApiClient::Base) do
      endpoint 'https://example.com'

      retry_on MyApiClient::ApiLimitError, wait: 10.seconds, attempts: 2
      error_handling json: { '$.errors.code': 10 }, raise: MyApiClient::ApiLimitError

      attr_reader :access_token

      def initialize(access_token:)
        @access_token = access_token
      end

      def get_users
        get 'users', headers: headers
      end

      private

      def headers
        {
          'Content-Type': 'application/json;charset=UTF-8',
          'Authorization': "Bearer #{access_token}",
        }
      end
    end
  end

  let(:api_client) { api_client_class.new(access_token: 'access_token') }

  it 'avoids sleep on testing' do
    beginning_on = Time.now
    response_body = { errors: { code: 10 } }.to_json
    expect { api_client.get_users }
      .to be_handled_as_an_error(MyApiClient::ApiLimitError)
      .after_retry(2).times
      .when_receive(body: response_body)
    ending_on = Time.now
    expect(ending_on - beginning_on).to be < 1.second
  end
end
