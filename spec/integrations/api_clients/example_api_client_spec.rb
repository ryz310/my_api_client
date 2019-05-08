# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ExampleApiClient, type: :api_client do
  let(:api_client) { described_class.new(access_token) }
  let(:access_token) { 'access_token' }

  describe '#create_user' do
    subject(:api_request) { api_client.create_user('Username') }

    before do
      stub_request(:post, endpoint)
        .with(headers: request_headers, body: request_body)
        .to_return(api_response)
    end

    let(:endpoint) { 'https://example.com/users' }
    let(:request_headers) do
      {
        'Content-Type': 'application/json;charset=UTF-8',
        'Authorization': 'Bearer access_token'
      }
    end
    let(:request_body) do
      { name: 'Username' }
    end

    context 'when return "201 Created"' do
      let(:api_response) do
        {
          status: 201,
          headers: { 'Content-Type': 'application/json' },
          body: response_body
        }
      end
      let(:response_body) do
        request_body.to_json
      end

      it { is_expected.to be_kind_of Sawyer::Resource }
    end
  end
end
