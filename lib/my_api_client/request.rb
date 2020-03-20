# frozen_string_literal: true

module MyApiClient
  # Provides HTTP request method.
  module Request
    include Basic
    include Pagination

    private

    # Executes HTTP request with relative URI.
    #
    # @param http_method [Symbol]
    #   HTTP method. e.g. `:get`, `:post`, `:patch` and `:delete`.
    # @param pathname [String]
    #   Pathname of the request target URL.
    #   It's joined with the defined by `endpoint`.
    # @param headers [Hash, nil]
    #   Request headers.
    # @param query [Hash, nil]
    #   Query string.
    # @param body [Hash, nil]
    #   Request body.
    # @return [Sawyer::Response]
    #   Response instance.
    def _request_with_relative_uri(http_method, pathname, headers, query, body)
      query_strings = query.present? ? '?' + query&.to_query : ''
      uri = URI.join(File.join(endpoint, pathname), query_strings)
      _request_with_absolute_uri(http_method, uri, headers, body)
    end

    # Executes HTTP request with absolute URI.
    #
    # @param http_method [Symbol]
    #   HTTP method. e.g. `:get`, `:post`, `:patch` and `:delete`.
    # @param uri [URI]
    #   Request target URI including query strings.
    # @param headers [Hash, nil]
    #   Request headers.
    # @param body [Hash, nil]
    #   Request body.
    # @return [Sawyer::Response]
    #   Response instance.
    def _request_with_absolute_uri(http_method, uri, headers, body)
      Executor.call(
        instance: self,
        request_params: Params::Request.new(http_method, uri, headers, body),
        request_logger: Logger.new(logger, http_method, uri),
        faraday_options: faraday_options
      )
    end

    # Generates options for the faraday instance.
    #
    # @return [Hash] Generated options.
    def faraday_options
      {
        request: {
          timeout: (http_read_timeout if respond_to?(:http_read_timeout)),
          open_timeout: (http_open_timeout if respond_to?(:http_open_timeout)),
        }.compact,
      }
    end
  end
end
