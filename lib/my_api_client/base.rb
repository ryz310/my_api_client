# frozen_string_literal: true

module MyApiClient
  # Description of Base
  class Base
    include MyApiClient::Config
    include MyApiClient::ErrorHandling
    include MyApiClient::Exceptions
    include MyApiClient::Request

    class_attribute :logger, instance_writer: false, default: ::Logger.new($stdout)
    class_attribute :error_handlers, instance_writer: false, default: []

    include MyApiClient::DefaultErrorHandlers

    # NOTE: This class **MUST NOT** implement #initialize method. Because it
    #       will become constraint that need call #super in the #initialize at
    #       definition of the child classes.
  end
end
