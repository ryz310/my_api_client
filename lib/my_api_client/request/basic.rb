# frozen_string_literal: true

module MyApiClient
  module Request
    # Provides basic HTTP request method.
    module Basic
      HTTP_METHODS = %i[get post put patch delete].freeze

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
          # @return [Sawyer::Resource]
          #   Response body instance.
          def #{http_method}(pathname, headers: nil, query: nil, body: nil)
            _#{http_method}(pathname, headers: headers, query: query, body: body).data
          end
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
          # @return [Sawyer::Response]
          #   Sawyer Response instance.
          def _#{http_method}(pathname, headers: nil, query: nil, body: nil)
            call(:_request_with_relative_uri, :#{http_method}, pathname, headers, query, body)
          end
        METHOD
      end
    end
  end
end
