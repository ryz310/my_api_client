# frozen_string_literal: true

module MyApiClient
  # Provides HTTP request method.
  module Request
    include Basic

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
