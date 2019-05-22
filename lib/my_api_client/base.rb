# frozen_string_literal: true

module MyApiClient
  class Base
    include MyApiClient::Config
    include MyApiClient::ErrorHandling

    %i[get post patch delete].each do |http_method|
      class_eval <<~METHOD, __FILE__, __LINE__ + 1
        def #{http_method}(url, headers: nil, query: nil, body: nil)
          request :#{http_method}, url, headers, query, body
        end
      METHOD
    end
    alias put patch

    # NOTE: This class **MUST NOT** implement an `#initialize` because to let
    #       the child classes free implement. It is not free to need calling
    #       `super()`.

    private

    def instance
      @instance ||= Request.new(endpoint, error_handlers, faraday_options)
    end

    def request(method, url, headers, query, body)
      instance.request(method, url, headers, query, body)
    end

    def faraday_options
      @faraday_options ||= {
        timeout: (request_timeout if respond_to?(:request_timeout)),
        open_timeout: (net_open_timeout if respond_to?(:net_open_timeout))
      }.compact
    end
  end
end
