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
  #   error_handling status_code: 500..599, raise: MyApiClient::ServerError do |params, logger|
  #     logger.warn 'Server error occurred.'
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
      #   Specify the validation target value path included in the response body
      #   as JsonPath expression.
      #   If specified `:forbid_nil`, it forbid `nil` at the response body.
      # @option with [Symbol]
      #   Calls specified method before raising exception when error detected.
      # @option raise [MyApiClient::Error]
      #   Raises specified error when an invalid response detected.
      #   Should be inherited `MyApiClient::Error` class.
      #   default: MyApiClient::Error
      # @option retry [TrueClass, Hash]
      #   If the error detected, retries the API request. Requires `raise` option.
      #   You can set `true` or `retry_on` options (`wait` and `attempts`).
      # @yield [MyApiClient::Params::Params, MyApiClient::Request::Logger]
      #   Executes the block before raising exception when error detected.
      #   Forbid to be used with the` retry` option.
      def error_handling(**options, &block)
        options[:block] = block
        retry_options = RetryOptionProcessor.call(error_handling_options: options)
        retry_on(options[:raise], **retry_options) if retry_options

        new_error_handlers = error_handlers.dup
        new_error_handlers << lambda { |instance, response|
          Generator.call(**options.merge(instance:, response:))
        }
        self.error_handlers = new_error_handlers
      end
    end
  end
end
