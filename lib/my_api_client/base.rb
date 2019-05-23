# frozen_string_literal: true

module MyApiClient
  class Base
    include MyApiClient::Config
    include MyApiClient::ErrorHandling
    include MyApiClient::Exceptions
    include MyApiClient::Request

    class_attribute :logger, instance_writer: false, default: ::Logger.new(STDOUT)
    class_attribute :error_handlers, instance_writer: false, default: []

    %i[get post patch delete].each do |http_method|
      class_eval <<~METHOD, __FILE__, __LINE__ + 1
        def #{http_method}(url, headers: nil, query: nil, body: nil)
          request :#{http_method}, url, headers, query, body
        end
      METHOD
    end
    alias put patch
  end
end
