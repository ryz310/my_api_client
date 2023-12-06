# frozen_string_literal: true

module MyApiClient
  module Request
    # Provides enumerable HTTP request method.
    module Pagination
      # Executes HTTP request with GET method, for pagination API. Expects the
      # pagination API to provide pagination links as part of the content of the response.
      #
      # @param pathname [String]
      #   Pathname of the request target URL. It's joined with the defined by `endpoint`.
      # @param paging [String, Proc]
      #   Specify the pagination link path included in the response body as JsonPath expression
      # @param headers [Hash, nil]
      #   Request headers.
      # @param query [Hash, nil]
      #   Query string.
      # @param body [Hash, nil]
      #   Request body. You should not specify it when use GET method.
      # @return [Enumerator::Lazy]
      #   Yields the pagination API response.
      def pageable_get(pathname, paging:, headers: nil, query: nil)
        Enumerator.new do |y|
          response = call(:_request_with_relative_uri, :get, pathname, headers, query, nil)
          loop do
            y << response.data

            next_uri = get_next_url(paging, response)
            break if next_uri.blank?

            response = call(:_request_with_absolute_uri, :get, next_uri, headers, nil)
          end
        end.lazy
      end

      alias pget pageable_get

      private

      # Returns the next URL for pagination
      #
      # @param paging [String, Proc]
      #   Specify the pagination link path included in the response body as JsonPath expression
      # @param response [MyApiClient::Response]
      #   The response object
      # @return [String, nil]
      #   The next URL for pagination
      def get_next_url(paging, response)
        case paging
        when String
          JsonPath.new(paging).first(response.body)
        when Proc
          paging.call(response)
        else
          raise ArgumentError, "Invalid paging argument: #{paging}"
        end
      end
    end
  end
end
