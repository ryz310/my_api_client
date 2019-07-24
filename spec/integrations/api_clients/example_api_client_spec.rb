# frozen_string_literal: true

require 'spec_helper'
require 'dummy_app/api_clients/example_api_client'

RSpec.describe ExampleApiClient, type: :api_client do
  let(:api_client) { described_class.new(access_token) }
  let(:access_token) { 'access_token' }
  let(:request_headers) do
    {
      'content-Type': 'application/json;charset=UTF-8',
      'Authorization': 'Bearer access_token',
    }
  end
  let(:logger) { instance_double(::Logger, info: nil, warn: nil, error: nil) }

  before do
    stub_request(http_method, endpoint)
      .with(headers: request_headers, body: request_body)
      .to_return(api_response)
    allow(described_class).to receive(:logger).and_return(logger)
  end

  shared_examples 'error handling' do
    describe 'network error' do
      let(:api_response) { {} }
      let(:agent) { instance_double(Sawyer::Agent) }

      before do
        allow(api_client).to receive(:agent).and_return(agent)
        allow(agent).to receive(:call).and_raise(Net::OpenTimeout)
      end

      it 'retries 3 times and raises an error at last' do
        expect { api_request! }.to raise_error(MyApiClient::NetworkError)
        expect(agent).to have_received(:call).exactly(4).times
      end
    end

    describe 'status code 400' do
      let(:api_response) do
        {
          status: 400,
          headers: { 'Content-Type': 'application/json' },
          body: nil,
        }
      end

      it { expect { api_request! }.to raise_error(MyApiClient::ClientError) }
    end

    describe 'status code 500' do
      let(:api_response) do
        {
          status: 500,
          headers: { 'Content-Type': 'application/json' },
          body: nil,
        }
      end

      it { expect { api_request! }.to raise_error(MyApiClient::ServerError) }
    end

    describe 'error code 10' do
      let(:api_response) do
        {
          status: 200,
          headers: { 'Content-Type': 'application/json' },
          body: {
            errors: {
              code: 10,
            },
          }.to_json,
        }
      end

      it { expect { api_request! }.to raise_error(MyApiClient::ClientError) }
    end

    describe 'error code 20' do
      let(:api_response) do
        {
          status: 200,
          headers: { 'Content-Type': 'application/json' },
          body: {
            errors: {
              code: 20,
            },
          }.to_json,
        }
      end

      before { allow(api_client).to receive(:_verify).and_call_original }

      it 'retries twice and raises an error at last' do
        expect { api_request! }.to raise_error(MyApiClient::ApiLimitError)
        expect(api_client).to have_received(:_verify).exactly(3).times
      end
    end

    describe 'error message "Sorry"' do
      let(:api_response) do
        {
          status: 200,
          headers: { 'Content-Type': 'application/json' },
          body: {
            errors: {
              code: 30,
              message: 'Sorry, something went wrong.',
            },
          }.to_json,
        }
      end

      it { expect { api_request! }.to raise_error(MyApiClient::ServerError) }
    end
  end

  describe '#create_user' do
    subject(:api_request!) { api_client.create_user('Username') }

    let(:http_method) { :post }
    let(:endpoint) { 'https://example.com/users' }
    let(:request_body) { { name: 'Username' } }

    context 'when return "201 Created"' do
      let(:api_response) do
        {
          status: 201,
          headers: { 'Content-Type': 'application/json' },
          body: {
            user: {
              id: 1,
              name: 'Username',
            },
          }.to_json,
        }
      end

      it { is_expected.to be_kind_of Sawyer::Resource }
    end

    it_behaves_like 'error handling'
  end

  describe '#read_users' do
    subject(:api_request!) { api_client.read_users }

    let(:http_method) { :get }
    let(:endpoint) { 'https://example.com/users' }
    let(:request_body) { nil }

    context 'when return "200 OK"' do
      let(:api_response) do
        {
          status: 200,
          headers: { 'Content-Type': 'application/json' },
          body: {
            users: [
              { id: 1, name: 'User 1' },
              { id: 2, name: 'User 2' },
              { id: 3, name: 'User 3' },
            ],
          }.to_json,
        }
      end

      it { is_expected.to be_kind_of Sawyer::Resource }
    end

    it_behaves_like 'error handling'
  end

  describe '#read_user' do
    subject(:api_request!) { api_client.read_user(1) }

    let(:http_method) { :get }
    let(:endpoint) { 'https://example.com/users/1' }
    let(:request_body) { nil }

    context 'when return "200 OK"' do
      let(:api_response) do
        {
          status: 200,
          headers: { 'Content-Type': 'application/json' },
          body: {
            user: {
              id: 1,
              name: 'User 1',
            },
          }.to_json,
        }
      end

      it { is_expected.to be_kind_of Sawyer::Resource }
    end

    it_behaves_like 'error handling'
  end

  describe '#update_user' do
    subject(:api_request!) { api_client.update_user(1, 'Modified') }

    let(:http_method) { :patch }
    let(:endpoint) { 'https://example.com/users/1' }
    let(:request_body) { { name: 'Modified' } }

    context 'when return "200 OK"' do
      let(:api_response) do
        {
          status: 200,
          headers: { 'Content-Type': 'application/json' },
          body: {
            user: {
              id: 1,
              name: 'Modified',
            },
          }.to_json,
        }
      end

      it { is_expected.to be_kind_of Sawyer::Resource }
    end

    it_behaves_like 'error handling'
  end

  describe '#delete_user' do
    subject(:api_request!) { api_client.delete_user(1) }

    let(:http_method) { :delete }
    let(:endpoint) { 'https://example.com/users/1' }
    let(:request_body) { nil }

    context 'when return "200 OK"' do
      let(:api_response) do
        {
          status: 200,
          headers: { 'Content-Type': 'application/json' },
          body: {}.to_json,
        }
      end

      it { is_expected.to be_kind_of Sawyer::Resource }
    end

    it_behaves_like 'error handling'
  end
end
