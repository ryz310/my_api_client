# frozen_string_literal: true

module MyApiClient
  module Request
    # Executes HTTP request with specified parameters.
    class Executor < ServiceAbstract
      # @param instance [MyApiClient::Base]
      #   The my_api_client instance.
      #   The instance method will be called on error handling.
      # @param request_params [MyApiClient::Params::Request]
      #   Request parameter instance.
      # @param request_logger [MyApiClient::Logger]
      #   Request logger instance.
      # @param faraday_options [Hash]
      #   Options for the faraday instance. Mainly used for timeout settings.
      # @return [Sawyer::Response]
      #   Response instance.
      # @raise [MyApiClient::Error]
      #   Raises on invalid response or network errors.
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

      # Executes HTTP request to the API.
      #
      # @return [Sawyer::Response]
      #   Response instance.
      # @raise [MyApiClient::NetworkError]
      #   Raises on any network errors.
      def api_request
        agent.call(*request_params.to_sawyer_args)
      rescue *NETWORK_ERRORS => e
        params = Params::Params.new(request_params, nil)
        raise MyApiClient::NetworkError.new(params, e)
      end

      # Verifies the response.
      #
      # @param response_params [Sawyer::Response]
      #   The target response.
      # @return [nil]
      #   Returns nil when a valid response.
      # @raise [MyApiClient::Error]
      #   Raises on any invalid response.
      def verify(response_params)
        params = Params::Params.new(request_params, response_params)
        find_error_handler(response_params)&.call(params, request_logger)
      end

      # Executes response verifyment. If an invalid response is detected, return
      # the error handler procedure. The error handlers defined later takes precedence.
      #
      # @param response_params [Sawyer::Response]
      #   The target response.
      # @return [nil]
      #   Returns nil when a valid response.
      # @return [Proc]
      #   Returns Proc when a invalid response.
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
