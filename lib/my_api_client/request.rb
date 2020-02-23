# frozen_string_literal: true

module MyApiClient
  # Description of Request
  module Request
    HTTP_METHODS = %i[get post patch delete].freeze

    HTTP_METHODS.each do |http_method|
      class_eval <<~METHOD, __FILE__, __LINE__ + 1
        # Executes HTTP request with #{http_method.upcase} method
        #
        # @param pathname [String]
        #   Pathname of the request target URL.
        #   It's joined with the defined `endpoint`.
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

    private

    # Executes HTTP request.
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
    def _request(http_method, uri, headers, body)
      request_params = Params::Request.new(http_method, uri, headers, body)
      request_logger = Logger.new(logger, http_method, uri)
      Executor.call(
        instance: self,
        request_params: request_params,
        request_logger: request_logger,
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
