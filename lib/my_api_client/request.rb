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
          response = _request :#{http_method}, pathname, headers, query, body, logger
          response.data
        end
      METHOD
    end
    alias put patch

    # Description of #_request
    #
    # @param http_method [Symbol] describe_http_method_here
    # @param pathname [String] describe_pathname_here
    # @param headers [Hash, nil] describe_headers_here
    # @param query [Hash, nil] describe_query_here
    # @param body [Hash, nil] describe_body_here
    # @param logger [::Logger] describe_logger_here
    # @return [Sawyer::Response] description_of_returned_object
    # rubocop:disable Metrics/ParameterLists
    def _request(http_method, pathname, headers, query, body, logger)
      processed_path = [common_path, pathname].join('/').gsub('//', '/')
      request_params = Params::Request.new(http_method, processed_path, headers, query, body)
      agent # Initializes for faraday
      request_logger = Logger.new(logger, faraday, http_method, processed_path)
      call(:_execute, request_params, request_logger)
    end
    # rubocop:enable Metrics/ParameterLists

    # Extracts schema and hostname from endpoint
    #
    # @example Extracts schema and hostname from 'https://example.com/path/to/api'
    #   schema_and_hostname # => 'https://example.com'
    # @return [String] description_of_returned_object
    def schema_and_hostname
      if _uri.default_port == _uri.port
        "#{_uri.scheme}://#{_uri.host}"
      else
        "#{_uri.scheme}://#{_uri.host}:#{_uri.port}"
      end
    end

    # Extracts pathname from endpoint
    #
    # @example Extracts pathname from 'https://example.com/path/to/api'
    #   common_path # => 'path/to/api'
    # @return [String] The pathanem
    def common_path
      _uri.path
    end

    private

    # Description of #agent
    #
    # @return [Sawyer::Agent] description_of_returned_object
    def agent
      @agent ||= Sawyer::Agent.new(schema_and_hostname, faraday: faraday)
    end

    # Description of #faraday
    #
    # @return [Faraday::Connection] description_of_returned_object
    def faraday
      @faraday ||=
        Faraday.new(
          nil,
          request: {
            timeout: (http_read_timeout if respond_to?(:http_read_timeout)),
            open_timeout: (http_open_timeout if respond_to?(:http_open_timeout)),
          }.compact
        )
    end

    # @return [URI] Returns a memoized URI instance
    def _uri
      @_uri ||= URI.parse(endpoint)
    end

    # Description of #_execute
    #
    # @param request_params [MyApiClient::Params::Request] describe_request_params_here
    # @param request_logger [MyApiClient::Logger] describe_request_logger_here
    # @return [Sawyer::Response] description_of_returned_object
    # @raise [MyApiClient::Error]
    def _execute(request_params, request_logger)
      request_logger.info('Start')
      response = agent.call(*request_params.to_sawyer_args)
      request_logger.info("Duration #{response.timing} sec")
      params = Params::Params.new(request_params, response)
      _verify(params, request_logger)
    rescue *NETWORK_ERRORS => e
      params ||= Params::Params.new(request_params, nil)
      request_logger.error("Network Error (#{e.message})")
      raise MyApiClient::NetworkError.new(params, e)
    rescue MyApiClient::Error => e
      request_logger.warn("Failure (#{response.status})")
      raise e
    else
      request_logger.info("Success (#{response.status})")
      response
    end

    # Description of #_verify
    #
    # @param params [MyApiClient::Params::Params] describe_params_here
    # @param request_logger [MyApiClient::Logger] describe_request_logger_here
    # @return [nil] description_of_returned_object
    # @raise [MyApiClient::Error]
    def _verify(params, request_logger)
      error_handler = _error_handling(params.response)
      return if error_handler.nil?

      error_handler.call(params, request_logger)
    end
  end
end
