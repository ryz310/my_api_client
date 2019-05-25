# frozen_string_literal: true

module MyApiClient
  class Base
    include MyApiClient::Config
    include MyApiClient::ErrorHandling
    include MyApiClient::Exceptions
    include MyApiClient::Request

    class_attribute :logger, instance_writer: false, default: ::Logger.new(STDOUT)
    class_attribute :error_handlers, instance_writer: false, default: []

    HTTP_METHODS = %i[get post patch delete].freeze

    HTTP_METHODS.each do |http_method|
      class_eval <<~METHOD, __FILE__, __LINE__ + 1
        # Description of #undefined
        #
        # @params url [String]
        # @params headers [Hash, nil]
        # @params query [Hash, nil]
        # @params body [Hash, nil]
        # @return [Sawyer::Resouce] description_of_returned_object
        def #{http_method}(url, headers: nil, query: nil, body: nil)
          request :#{http_method}, url, headers, query, body
        end
      METHOD
    end
    alias put patch
  end
end
