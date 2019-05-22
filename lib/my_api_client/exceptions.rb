# frozen_string_literal: true

module MyApiClient
  module Exceptions
    extend ActiveSupport::Concern
    include ActiveSupport::Rescuable

    private

    attr_reader :retry_count, :method_name, :args

    NETWORK_ERRORS = [
      Faraday::ClientError,
      OpenSSL::SSL::SSLError,
      Net::OpenTimeout,
      SocketError
    ].freeze

    class_methods do
      def retry_on_network_errors(wait: 0.1.seconds, attempts: 3)
        rescue_from(*NETWORK_ERRORS) do |error|
          if retry_count < attempts
            retry_call(error, wait)
          elsif block_given?
            yield self, error
          else
            logger.error "Stopped retrying #{self.class} due to a #{exception}, " \
                         "which reoccurred on #{retry_count} attempts. " \
                         "The original exception was #{error.cause.inspect}."
            raise error
          end
        end
      end
    end

    def call(method_name, *args)
      @method_name = method_name
      @args = args
      send(method_name, *args)
    rescue StandardError => e
      @retry_count ||= 0
      raise unless rescue_with_handler(e)
    end

    def retry_call(_error, wait)
      sleep(wait)
      @retry_count += 1
      call(method_name, *args)
    end
  end
end
