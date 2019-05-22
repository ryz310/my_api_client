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
      call(:execute, method, url, headers, query, body)
    end

    private

    attr_reader :error_handlers, :faraday, :agent, :logger

    def execute(method, url, headers, query, body)
      response = agent.call(method, url, body, headers: headers, query: query)
      logger.info("Duration #{response.timing} sec")
      params = [] # TODO: create a params
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
