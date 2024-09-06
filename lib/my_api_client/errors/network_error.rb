# frozen_string_literal: true

module MyApiClient
  NETWORK_ERRORS = [
    Faraday::TimeoutError,
    Faraday::ConnectionFailed,
    Faraday::SSLError,
    OpenSSL::SSL::SSLError,
    Net::OpenTimeout,
    Net::ReadTimeout,
    SocketError,
  ].freeze

  # Raises it when occurred to some network error
  class NetworkError < Error
    attr_reader :original_error

    # Initialize the error class
    #
    # @param params [MyApiClient::Params::Params]
    #   The request and response parameters
    # @param original_error [StandardError]
    #   Some network error
    def initialize(params = nil, original_error = nil)
      @original_error = original_error
      super(params, original_error&.message)
    end

    # Returns contents as string for to be readable for human
    #
    # @return [String] Contents as string
    def inspect
      { error: original_error, params: }.inspect
    end

    # Generate metadata for bugsnag.
    #
    # @return [Hash] Metadata for bugsnag
    def metadata
      super&.merge(original_error: original_error&.inspect)
    end
  end
end
