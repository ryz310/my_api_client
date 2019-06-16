# frozen_string_literal: true

module MyApiClient
  module Params
    # Description of Params
    class Params
      attr_reader :request, :response

      # Description of #initialize
      #
      # @param request [MyApiClient::Params::Request] describe_request_here
      # @param response [Sawyer::Response, nil] describe_response_here
      def initialize(request, response)
        @request = request
        @response = response
      end

      # Generate metadata for bugsnag.
      # It will integrate request and response params.
      # Blank parameter will be omitted.
      #
      # @return [Hash] Metadata for bugsnag
      def metadata
        request_metadata.merge(response_metadata)
      end
      alias to_bugsnag metadata

      # Returns contents as string for to be readable for human
      #
      # @return [String] Contents as string
      def inspect
        { request: request, response: response }.inspect
      end

      private

      # Generate metadata from request params.
      # It will be added prefix "request_".
      #
      # @return [Hash] Metadata for bugsnag
      def request_metadata
        if request.present?
          request.metadata.each_with_object({}) do |(key, value), memo|
            memo[:"request_#{key}"] = value
          end
        else
          {}
        end
      end

      # Generate metadata from response params.
      # It will be added prefix "response_".
      #
      # @return [Hash] Metadata for bugsnag
      def response_metadata
        if response.present?
          data = response.data
          body = data.respond_to?(:to_h) ? data.to_h : data
          {
            response_status: response.status,
            response_headers: response.headers,
            response_body: body,
          }.compact
        else
          {}
        end
      end
    end
  end
end
