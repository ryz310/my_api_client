# frozen_string_literal: true

module MyApiClient
  class Request
    include MyApiClient::Exceptions

    def initialize(endpoint, error_handlers, options)
      @error_handlers = error_handlers
      @faraday = Faraday.new(nil, request: options)
      @agent = Sawyer::Agent.new(endpoint, faraday: faraday)
    end

    def request(method, url, headers, query, body)
      @logger = Logger.new(faraday, method, url)
      request_params = Params::Request.new(method, url, headers, query, body)
      call(:execute, request_params)
    end

    private

    attr_reader :error_handlers, :faraday, :agent, :logger

    def execute(request_params)
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
