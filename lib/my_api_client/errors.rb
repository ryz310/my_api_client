# frozen_string_literal: true

module MyApiClient
  # The ancestor class for all API request error
  class Error < StandardError
    attr_reader :params
    delegate :metadata, to: :params
    alias to_bugsnag metadata

    # Initialize the error class
    #
    # @param params [MyApiClient::Params::Params]
    #   The request and response parameters
    # @param error_message [String]
    #   The error description
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

  # NOTE: The built-in error classes are following. Although they are prepared
  #       to save the trouble of defining, but you can create any error classes
  #       which inherit the ancestor error class.
end
