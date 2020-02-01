# frozen_string_literal: true

module MyApiClient
  # Description of Logger
  class Logger
    attr_reader :logger, :method, :uri

    LOG_LEVEL = %i[debug info warn error fatal].freeze

    # Description of #initialize
    #
    # @param logger [::Logger] describe_logger_here
    # @param method [String] HTTP method
    # @param uri [URI] Target URI
    def initialize(logger, method, uri)
      @logger = logger
      @method = method.to_s.upcase
      @uri = uri
    end

    LOG_LEVEL.each do |level|
      class_eval <<~METHOD, __FILE__, __LINE__ + 1
        def #{level}(message)
          logger.#{level}(format(message))
        end
      METHOD
    end

    private

    def format(message)
      "API request `#{method} #{uri}`: \"#{message}\""
    end
  end
end
