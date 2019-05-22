# frozen_string_literal: true

module MyApiClient
  class Base
    include MyApiClient::Exceptions

    %i[get post patch delete].each do |http_method|
      class_eval <<~METHOD, __FILE__, __LINE__ + 1
        def #{http_method}(url, headers: nil, query: nil, body: nil)
          request :#{http_method}, url, headers, query, body
        end
      METHOD
    end
    alias put patch

    def request(method, url, headers, query, body)
      agent = Sawyer::Agent.new(endpoint)
      agent.call(method, url, body, headers: headers, query: query).data
    end

    def self.endpoint(endpoint)
      define_method :endpoint, -> { endpoint }
    end

    def self.request_timeout(request_timeout)
      define_method :request_timeout, -> { request_timeout }
    end

    def self.net_open_timeout(net_open_timeout)
      define_method :net_open_timeout, -> { net_open_timeout }
    end

    def self.error_handling(status_code: nil, json: nil, with: nil)
      # TODO: Implemnt this
    end
  end
end
