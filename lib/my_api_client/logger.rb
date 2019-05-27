# frozen_string_literal: true

module MyApiClient
  # Description of Logger
  class Logger
    attr_reader :logger, :method, :pathname

    LOG_LEVEL = %i[debug info warn error fatal].freeze

    # Description of #initialize
    #
    # @param logger [::Logger] describe_logger_here
    # @param faraday [Faraday::Connection] describe_faraday_here
    # @param method [String] HTTP method
    # @param pathname [String] The path name
    def initialize(logger, faraday, method, pathname)
      @logger = logger
      @method = method.to_s.upcase
      @pathname = faraday.build_exclusive_url(pathname)
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
      "API request `#{method} #{pathname}`: \"#{message}\""
    end
  end
end
