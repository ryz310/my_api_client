# frozen_string_literal: true

module MyApiClient
  # Description of Request
  module Request
    HTTP_METHODS = %i[get post patch delete].freeze

    HTTP_METHODS.each do |http_method|
      class_eval <<~METHOD, __FILE__, __LINE__ + 1
        # Description of ##{http_method}
        #
        # @param pathname [String]
        # @param headers [Hash, nil]
        # @param query [Hash, nil]
        # @param body [Hash, nil]
        # @return [Sawyer::Resouce] description_of_returned_object
        def #{http_method}(pathname, headers: nil, query: nil, body: nil)
          query_strings = query.present? ? '?' + query&.to_query : ''
          uri = URI.join(File.join(endpoint, pathname), query_strings)
          response = call(:_request, :#{http_method}, uri, headers, body)
          response.data
        end
      METHOD
    end
    alias put patch

    # Description of #_request
    #
    # @param http_method [Symbol] describe_http_method_here
    # @param uri [URI] describe_uri_here
    # @param headers [Hash, nil] describe_headers_here
    # @param body [Hash, nil] describe_body_here
    # @return [Sawyer::Response] description_of_returned_object
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

    private

    # Description of #faraday_options
    #
    # @return [Hash] description_of_returned_object
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
