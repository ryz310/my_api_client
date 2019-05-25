# frozen_string_literal: true

module MyApiClient
  class Logger
    attr_reader :logger, :method, :url

    LOG_LEVEL = %i[debug info warn error fatal].freeze

    # Description of #initialize
    #
    # @param logger [::Logger] describe_logger_here
    # @param faraday [Faraday::Connection] describe_faraday_here
    # @param method [String] HTTP method
    # @param url [String] The path name
    def initialize(logger, faraday, method, url)
      @logger = logger
      @method = method.to_s.upcase
      @url = faraday.build_exclusive_url(url)
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
      "API request `#{method} #{url}`: \"#{message}\""
    end
  end
end
