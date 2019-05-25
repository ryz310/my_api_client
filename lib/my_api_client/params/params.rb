# frozen_string_literal: true

module MyApiClient
  module Params
    class Params
      attr_reader :request, :response

      # Description of #initialize
      #
      # @param request [MyApiClient::Params::Request] describe_request_here
      # @param response [Sawyer::Response] describe_response_here
      def initialize(request, response)
        @request = request
        @response = response
      end

      # Returns contents as string for to be readable for human
      #
      # @return [String] Contents as string
      def inspect
        { request: request, response: response }.inspect
      end
    end
  end
end
