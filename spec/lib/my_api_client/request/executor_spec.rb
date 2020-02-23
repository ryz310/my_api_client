# frozen_string_literal: true

RSpec.describe MyApiClient::Request::Executor do
  describe '.call' do
    subject(:execute) do
      described_class.call(
        instance: instance,
        request_params: request_params,
        request_logger: request_logger,
        faraday_options: faraday_options
      )
    end

    let(:safe_execution) do
      begin
        execute
      rescue MyApiClient::Error
        nil
      end
    end

    let(:instance) do
      instance_double(MyApiClient::Base, error_handlers: error_handlers)
    end

    let(:request_params) do
      instance_double(MyApiClient::Params::Request, to_sawyer_args: sawyer_args)
    end

    let(:request_logger) do
      instance_double(MyApiClient::Request::Logger, info: nil, warn: nil)
    end

    let(:faraday_options) do
      { request: { timeout: 3.seconds } }
    end

    let(:error_handlers) do
      [error_handler_generator_1, error_handler_generator_2, error_handler_generator_3]
    end

    let(:error_handler_generator_1) { instance_double(Proc, call: nil) }
    let(:error_handler_generator_2) { instance_double(Proc, call: nil) }
    let(:error_handler_generator_3) { instance_double(Proc, call: nil) }

    let(:sawyer_args) do
      [:post, 'https://example.com', { name: 'John' }, { headers: nil }]
    end

    let(:faraday) { instance_double(Faraday) }
    let(:agent) { instance_double(Sawyer::Agent, call: response) }
    let(:params) { instance_double(MyApiClient::Params::Params, metadata: {}) }
    let(:response) { instance_double(Sawyer::Response, timing: 0.1, status: 200) }

    before do
      allow(Faraday).to receive(:new).and_return(faraday)
      allow(Sawyer::Agent).to receive(:new).and_return(agent)
      allow(MyApiClient::Params::Params).to receive(:new).and_return(params)
    end

    shared_examples 'initialization' do
      it 'builds faraday and sawyer agent instances with options' do
        safe_execution
        expect(Faraday).to have_received(:new).with(nil, faraday_options).ordered
        expect(Sawyer::Agent).to have_received(:new).with('', faraday: faraday)
      end
    end

    shared_examples 'executes API request' do
      it 'calls Sawyer::Agent#call with request parameters' do
        safe_execution
        expect(agent).to have_received(:call).with(*sawyer_args)
      end

      it 'builds an integration parameter with request and response parameters' do
        safe_execution
        expect(MyApiClient::Params::Params)
          .to have_received(:new).with(request_params, response)
      end

      it 'searches error handlers in reverse order' do
        safe_execution
        expect(error_handler_generator_3).to have_received(:call).with(instance, response).ordered
        expect(error_handler_generator_2).to have_received(:call).with(instance, response).ordered
        expect(error_handler_generator_1).to have_received(:call).with(instance, response).ordered
      end
    end

    context 'when the API request succeeds' do
      it_behaves_like 'initialization'
      it_behaves_like 'executes API request'

      it 'logs the API request flow as successful' do
        execute
        expect(request_logger).to have_received(:info).with('Start').ordered
        expect(request_logger).to have_received(:info).with('Duration 0.1 sec').ordered
        expect(request_logger).to have_received(:info).with('Success (200)').ordered
      end

      it 'returns the API response' do
        expect(execute).to eq response
      end
    end

    context 'when the API request fails' do
      let(:error_handler_generator_1) { instance_double(Proc, call: error_handler) }
      let(:error_handler) { instance_double(Proc) }

      before do
        allow(error_handler).to receive(:call).and_raise(MyApiClient::Error, params)
      end

      it_behaves_like 'initialization'
      it_behaves_like 'executes API request'

      it 'logs the API request flow as failure' do
        safe_execution
        expect(request_logger).to have_received(:info).with('Start').ordered
        expect(request_logger).to have_received(:info).with('Duration 0.1 sec').ordered
        expect(request_logger).to have_received(:warn).with('Failure (MyApiClient::Error)').ordered
      end

      it 'runs the found error handler with integration parameters and logger instance' do
        safe_execution
        expect(error_handler).to have_received(:call).with(params, request_logger)
      end

      it 'raises an error that inherits MyApiClient::Error' do
        expect { execute }.to raise_error(MyApiClient::Error)
      end
    end

    context 'when a network error occurs' do
      let(:network_error) { Net::OpenTimeout }

      before do
        allow(agent).to receive(:call).and_raise(network_error)
        allow(MyApiClient::NetworkError).to receive(:new).and_call_original
      end

      it_behaves_like 'initialization'

      it 'logs the API request flow as network error' do
        safe_execution
        expect(request_logger).to have_received(:info).with('Start').ordered
        expect(request_logger).not_to have_received(:info).with(/Duration/)
        expect(request_logger).to have_received(:warn).with('Failure (Net::OpenTimeout)').ordered
      end

      it 'builds an integration parameter with only request parameter' do
        safe_execution
        expect(MyApiClient::Params::Params).to have_received(:new).with(request_params, nil)
      end

      it 'wraps detected network error in MyApiClient::NetworkError' do
        safe_execution
        expect(MyApiClient::NetworkError).to have_received(:new).with(params, network_error)
      end

      it 'raises MyApiClient::NetworkError' do
        expect { execute }.to raise_error(MyApiClient::NetworkError)
      end
    end
  end
end
