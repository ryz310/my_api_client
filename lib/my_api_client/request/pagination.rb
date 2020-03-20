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
      # @param paging [String]
      #   Specify the pagination link path included in the response body as JsonPath expression
      # @param headers [Hash, nil]
      #   Request headers.
      # @param query [Hash, nil]
      #   Query string.
      # @param body [Hash, nil]
      #   Request body. You should not specify it when use GET method.
      # @return [Enumerator]
      #   Yields the pagination API response.
      def pageable_get(pathname, paging:, headers: nil, query: nil)
        Enumerator.new do |y|
          response = call(:_request_with_relative_uri, :get, pathname, headers, query, nil)
          loop do
            y << response.data

            next_uri = JsonPath.new(paging).first(response.body)
            break if next_uri.blank?

            response = call(:_request_with_absolute_uri, :get, next_uri, headers, nil)
          end
        end
      end

      alias pget pageable_get
    end
  end
end
