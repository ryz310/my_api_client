# frozen_string_literal: true

module MyApiClient
  # Description of Base
  class Base
    include MyApiClient::Config
    include MyApiClient::ErrorHandling
    include MyApiClient::Exceptions
    include MyApiClient::Request

    if ActiveSupport::VERSION::STRING >= '5.2.0'
      class_attribute :logger, instance_writer: false, default: ::Logger.new(STDOUT)
      class_attribute :error_handlers, instance_writer: false, default: []
    else
      class_attribute :logger
      class_attribute :error_handlers
      self.logger = ::Logger.new(STDOUT)
      self.error_handlers = []
    end

    # NOTE: This class **MUST NOT** implement #initialize method. Because it
    #       will become constraint that need call #super in the #initialize at
    #       definition of the child classes.
  end
end
