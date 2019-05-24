# frozen_string_literal: true

module MyApiClient
  module Request
    # Description of #request
    #
    # @param http_method [Symbol] describe_http_method_here
    # @param url [String] describe_url_here
    # @param headers [Hash, nil] describe_headers_here
    # @param query [Hash, nil] describe_query_here
    # @param body [Hash, nil] describe_body_here
    # @return [Sawyer::Resource] description_of_returned_object
    def request(http_method, url, headers, query, body)
      request_params = Params::Request.new(http_method, url, headers, query, body)
      logger = Logger.new(faraday, http_method, url)
      call(:execute, request_params, logger)
    end

    private

    def agent
      @agent ||= Sawyer::Agent.new(endpoint, faraday: faraday)
    end

    def faraday
      @faraday ||=
        Faraday.new(
          nil,
          request: {
            timeout: (request_timeout if respond_to?(:request_timeout)),
            open_timeout: (net_open_timeout if respond_to?(:net_open_timeout))
          }.compact
        )
    end

    def execute(request_params, logger)
      logger.info('Start')
      response = agent.call(*request_params.to_sawyer_args)
      logger.info("Duration #{response.timing} sec")
      params = Params::Params.new(request_params, response)
      verify(params, logger)
    rescue MyApiClient::Error => e
      logger.warn("Failure (#{response.status})")
      raise e
    else
      logger.info("Success (#{response.status})")
      response.data
    end

    def verify(params, logger)
      case error_handler = error_handling(params.response)
      when Proc
        error_handler.call(params, logger)
      when Symbol
        send(error_handler, params, logger)
      end
    end
  end
end
