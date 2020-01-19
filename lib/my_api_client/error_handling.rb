# frozen_string_literal: true

module MyApiClient
  # Provides `error_handling` as DSL.
  #
  # @note
  #   You need to define `class_attribute: error_handler, default: []` for the
  #   included class.
  # @example
  #   error_handling status_code: 200, json: :forbid_nil
  #   error_handling status_code: 400..499, raise: MyApiClient::ClientError
  #   error_handling status_code: 500..599 do |params, logger|
  #     logger.warn 'Server error occurred.'
  #     raise MyApiClient::ServerError, params
  #   end
  #
  #   error_handling json: { '$.errors.code': 10..19 }, with: :my_error_handling
  #   error_handling json: { '$.errors.code': 20 }, raise: MyApiClient::ApiLimitError
  #   error_handling json: { '$.errors.message': /Sorry/ }, raise: MyApiClient::ServerError
  #   error_handling json: { '$.errors.code': :negative? }
  module ErrorHandling
    extend ActiveSupport::Concern

    class_methods do
      # Definition of an error handling
      #
      # @param options [Hash]
      #   Options for this generator
      # @option status_code [String, Range, Integer, Regexp]
      #   Verifies response HTTP status code and raises error if matched
      # @option json [Hash, Symbol]
      #   Verifies response body as JSON and raises error if matched.
      #   If specified `:forbid_nil`, it forbid `nil` on response_body.
      # @option with [Symbol]
      #   Calls specified method when error detected
      # @option raise [MyApiClient::Error]
      #   Raises specified error when an invalid response detected.
      #   Should be inherited `MyApiClient::Error` class.
      #   default: MyApiClient::Error
      # @option retry [TrueClass, Hash]
      #   If the error detected, retries the API request. Requires `raise` option.
      #   You can set `true` or `retry_on` options (`wait` and `attempts`).
      # @yield [MyApiClient::Params::Params, MyApiClient::Logger]
      #   Executes the block when error detected.
      #   Forbid to be used with the` retry` option.
      def error_handling(**options, &block)
        options[:block] = block
        retry_options = ProcessRetryOption.call(error_handling_options: options)
        retry_on(options[:raise], **retry_options) if retry_options

        temp = error_handlers.dup
        temp << ->(response) { Generator.call(**options.merge(response: response)) }
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
