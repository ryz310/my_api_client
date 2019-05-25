# frozen_string_literal: true

module MyApiClient
  class Base
    include MyApiClient::Config
    include MyApiClient::ErrorHandling
    include MyApiClient::Exceptions
    include MyApiClient::Request

    class_attribute :logger, instance_writer: false, default: ::Logger.new(STDOUT)
    class_attribute :error_handlers, instance_writer: false, default: []

    # NOTE: This class **MUST NOT** implement #initialize method. Because it
    #       will become constraint that need call #super in the #initialize at
    #       definition of the child classes.

    HTTP_METHODS = %i[get post patch delete].freeze

    HTTP_METHODS.each do |http_method|
      class_eval <<~METHOD, __FILE__, __LINE__ + 1
        # Description of #undefined
        #
        # @param url [String]
        # @param headers [Hash, nil]
        # @param query [Hash, nil]
        # @param body [Hash, nil]
        # @return [Sawyer::Resouce] description_of_returned_object
        def #{http_method}(url, headers: nil, query: nil, body: nil)
          request :#{http_method}, url, headers, query, body, logger
        end
      METHOD
    end
    alias put patch
  end
end
