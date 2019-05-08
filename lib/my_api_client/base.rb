# frozen_string_literal: true

module MyApiClient
  class Base
    include MyApiClient::Exceptions

    def get(url, headers: nil, query: nil, body: nil)
      request :get, url, headers, query, body
    end

    def post(url, headers: nil, query: nil, body: nil)
      request :post, url, headers, query, body
    end

    def patch(url, headers: nil, query: nil, body: nil)
      request :patch, url, headers, query, body
    end
    alias put patch

    def delete(url, headers: nil, query: nil, body: nil)
      request :delete, url, headers, query, body
    end

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

    def self.error_handling(status_code: nil, json: nil, then: nil)
      # TODO: Implemnt this
    end
  end
end
