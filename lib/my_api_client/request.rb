# frozen_string_literal: true

module MyApiClient
  module Request
    def request(method, url, headers, query, body)
      request_params = Params::Request.new(method, url, headers, query, body)
      logger = Logger.new(faraday, method, url)
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
      response = agent.call(*request_params.to_sawyer_args)
      logger.info("Duration #{response.timing} sec")
      params = Params::Params.new(request_params, response)
      verify(params)
      response.data
    end

    def verify(params)
      error_handler = error_handlers.detect { |h| h.call(params.response) }
      case error_handler
      when Proc
        error_handler.call(params, logger)
      when Symbol
        send(error_handler, params, logger)
      end
    end
  end
end
