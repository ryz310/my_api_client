# frozen_string_literal: true

module MyApiClient
  module Request
    # Description of Executor
    class Executor < ServiceAbstract
      # Description of #_execute
      #
      # @param instance [MyApiClient::Base]
      # @param request_params [MyApiClient::Params::Request]
      # @param request_logger [MyApiClient::Logger]
      # @param faraday_options [Hash]
      # @return [Sawyer::Response]
      # @raise [MyApiClient::Error]
      def initialize(instance:, request_params:, request_logger:, faraday_options:)
        @instance = instance
        @request_params = request_params
        @request_logger = request_logger
        faraday = Faraday.new(nil, faraday_options)
        @agent = Sawyer::Agent.new('', faraday: faraday)
      end

      private

      attr_reader :instance, :request_params, :request_logger, :agent

      def call
        request_logger.info('Start')
        response = api_request
        request_logger.info("Duration #{response.timing} sec")
        verify(response)
      rescue MyApiClient::Error => e
        request_logger.warn("Failure (#{e.message})")
        raise
      else
        request_logger.info("Success (#{response.status})")
        response
      end

      # Description of #api_request
      #
      # @return [Sawyer::Response]
      # @raise [MyApiClient::NetworkError]
      def api_request
        agent.call(*request_params.to_sawyer_args)
      rescue *NETWORK_ERRORS => e
        params = Params::Params.new(request_params, nil)
        raise MyApiClient::NetworkError.new(params, e)
      end

      # Description of #verify
      #
      # @param response_params [Sawyer::Response]
      # @return [nil]
      # @raise [MyApiClient::Error]
      def verify(response_params)
        params = Params::Params.new(request_params, response_params)
        find_error_handler(response_params)&.call(params, request_logger)
      end

      # The error handlers defined later takes precedence
      #
      # @param response_params [Sawyer::Response]
      # @return [Proc, nil]
      def find_error_handler(response_params)
        instance.error_handlers.reverse_each do |error_handler|
          result = error_handler.call(instance, response_params)
          return result unless result.nil?
        end
        nil
      end
    end
  end
end
