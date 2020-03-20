# frozen_string_literal: true

module MyApiClient
  module Request
    # Provides basic HTTP request method.
    module Basic
      HTTP_METHODS = %i[get post patch delete].freeze

      HTTP_METHODS.each do |http_method|
        class_eval <<~METHOD, __FILE__, __LINE__ + 1
          # Executes HTTP request with #{http_method.upcase} method
          #
          # @param pathname [String]
          #   Pathname of the request target URL.
          #   It's joined with the defined by `endpoint`.
          # @param headers [Hash, nil]
          #   Request headers.
          # @param query [Hash, nil]
          #   Query string.
          # @param body [Hash, nil]
          #   Request body. You should not specify it when use GET method.
          # @return [Sawyer::Resouce]
          #   Response body instance.
          def #{http_method}(pathname, headers: nil, query: nil, body: nil)
            query_strings = query.present? ? '?' + query&.to_query : ''
            uri = URI.join(File.join(endpoint, pathname), query_strings)
            response = call(:_request, :#{http_method}, uri, headers, body)
            response.data
          end
        METHOD
      end

      alias put patch
    end
  end
end
