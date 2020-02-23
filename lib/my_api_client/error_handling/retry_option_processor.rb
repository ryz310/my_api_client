# frozen_string_literal: true

module MyApiClient
  module ErrorHandling
    # Processes the `retry` option.
    class RetryOptionProcessor < ServiceAbstract
      # @param error_handling_options [Hash]
      #   Options for the retry.
      # @option raise [MyApiClient::Error]
      #   Raises specified error when an invalid response detected.
      #   Should be inherited `MyApiClient::Error` class.
      # @option retry [TrueClass, Hash]
      #   If the error detected, retries the API request. Requires `raise` option.
      #   You can set `true` or `retry_on` options (`wait` and `attempts`).
      # @option block [Proc, nil]
      #   Executes the block when error detected.
      #   The `block` option is forbidden to be used with the` retry` option.
      # @return [Hash]
      #   Options for `retry_on`.
      # @return [nil]
      #   If `retry` is not specified.
      def initialize(error_handling_options:)
        @error_handling_options = error_handling_options
      end

      private

      attr_reader :error_handling_options

      def call
        retry_options = error_handling_options.delete(:retry)
        return unless retry_options

        verify_error_handling_options
        retry_options = {} unless retry_options.is_a? Hash
        retry_options
      end

      # Requires `retry` option and forbid `block` option.
      def verify_error_handling_options
        if !error_handling_options[:raise]
          raise 'The `retry` option requires `raise` option. ' \
                'Please set any `raise` option, which inherits `MyApiClient::Error` class.'
        elsif error_handling_options[:block]
          raise 'The `block` option is forbidden to be used with the` retry` option.'
        end
      end
    end
  end
end
