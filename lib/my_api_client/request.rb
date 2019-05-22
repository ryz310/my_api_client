# frozen_string_literal: true

module MyApiClient
  module Request
    include MyApiClient::Exceptions

    def request(method, url, headers, query, body)
      # TODO: Wrap with a factory class
      logger = Logger.new(faraday, method, url)
      agent = Sawyer::Agent.new(endpoint, faraday: faraday)
      agent.call(method, url, body, headers: headers, query: query).tap do |response|
        logger.info("Duration #{response.timing} sec")
        params = [] # TODO: create a params
        verify(params, logger)
      end.data
    end

    def verify(params, logger)
      error_handler = error_handlers.find { |h| h.call(params.response) }

      case error_handler
      when Proc
        error_handler.call(params, logger)
      when Symbol
        send(error_handler, params, logger)
      end
    end

    %i[get post patch delete].each do |http_method|
      class_eval <<~METHOD, __FILE__, __LINE__ + 1
        def #{http_method}(url, headers: nil, query: nil, body: nil)
          request :#{http_method}, url, headers, query, body
        end
      METHOD
    end
    alias put patch

    private

    def faraday
      Faraday.new(nil, request: request_option)
    end

    def request_option
      @request_option ||= {
        timeout: respond_to?(:request_timeout) ? request_timeout : nil,
        open_timeout: respond_to?(:request_open_timeout) ? request_open_timeout : nil
      }.compact
    end
  end
end
