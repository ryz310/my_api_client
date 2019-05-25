# frozen_string_literal: true

module MyApiClient
  # The ancestor class for all API request error
  class Error < StandardError
    attr_reader :params

    # Description of #initialize
    #
    # @param params [MyApiClient::Params::Params] describe_params_here
    # @param error_message [String] default: nil
    def initialize(params, error_message = nil)
      @params = params
      super error_message
    end

    # Returns contents as string for to be readable for human
    #
    # @return [String] Contents as string
    def inspect
      { error: super, params: params }.inspect
    end
  end

  NETWORK_ERRORS = [
    Faraday::ClientError,
    OpenSSL::SSL::SSLError,
    Net::OpenTimeout,
    SocketError,
  ].freeze

  # Raises it when occurred to some network error
  class NetworkError < Error
    attr_reader :original_error

    # Description of #initialize
    #
    # @param params [MyApiClient::Params::Params] describe_params_here
    # @param original_error [StandardError] Some network error
    def initialize(params, original_error)
      @original_error = original_error
      super params, original_error.message
    end

    # Returns contents as string for to be readable for human
    #
    # @return [String] Contents as string
    def inspect
      { error: original_error, params: params }.inspect
    end
  end

  # NOTE: The built-in error classes are following. Although they are prepared
  #       to save the trouble of defining, but you can create any error classes
  #       which inherit the ancestor error class.

  # For 4xx client error
  class ClientError < Error; end

  # For 5xx server error
  class ServerError < Error; end

  # For API request limit error
  class ApiLimitError < Error; end
end
