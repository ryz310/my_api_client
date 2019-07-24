# frozen_string_literal: true

module MyApiClient
  # Provides `error_handling` as DSL.
  #
  # @note
  #   You need to define `class_attribute: error_handler, default: []` for the
  #   included class.
  # @example
  #   error_handling status_code: 400..499, raise: MyApiClient::ClientError
  #   error_handling status_code: 500..599 do |params, logger|
  #     logger.warn 'Server error occurred.'
  #     raise MyApiClient::ServerError, params
  #   end
  #
  #   error_handling json: { '$.errors.code': 10..19 }, with: :my_error_handling
  #   error_handling json: { '$.errors.code': 20 }, raise: MyApiClient::ApiLimitError
  #   error_handling json: { '$.errors.message': /Sorry/ }, raise: MyApiClient::ServerError
  module ErrorHandling
    extend ActiveSupport::Concern

    class_methods do
      # Definition of an error handling
      #
      # @param status_code [String, Range, Integer, Regexp]
      #   Verifies response HTTP status code and raises error if matched
      # @param json [Hash]
      #   Verifies response body as JSON and raises error if matched
      # @param with [Symbol]
      #   Calls specified method when error detected
      # @param raise [MyApiClient::Error]
      #   Raises specified error when error detected. default: MyApiClient::Error
      # @param block [Proc]
      #   Executes the block when error detected
      def error_handling(status_code: nil, json: nil, with: nil, raise: MyApiClient::Error, &block)
        temp = error_handlers.dup
        temp << lambda { |response|
          Generator.call(
            response: response,
            status_code: status_code,
            json: json,
            with: with,
            raise: raise,
            block: (block if block_given?)
          )
        }
        self.error_handlers = temp
      end
    end

    # The error handlers defined later takes precedence
    #
    # @param response [Sawyer::Response] describe_params_here
    # @return [Proc, Symbol, nil] description_of_returned_object
    def error_handling(response)
      error_handlers.reverse_each do |error_handler|
        result = error_handler.call(response)
        return result unless result.nil?
      end
      nil
    end
  end
end
