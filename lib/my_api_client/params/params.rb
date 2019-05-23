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
    end
  end
end
