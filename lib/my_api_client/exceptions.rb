# frozen_string_literal: true

module MyApiClient
  module Exceptions
    extend ActiveSupport::Concern
    include ActiveSupport::Rescuable

    # Description of #call
    #
    # @param args [Array<Object>] describe_args_here
    # @return [Object] description_of_returned_object
    def call(*args)
      @args = args
      send(*args)
    rescue StandardError => e
      @retry_count ||= 0
      raise unless rescue_with_handler(e)
    end

    private

    attr_reader :retry_count, :method_name, :args

    NETWORK_ERRORS = [
      Faraday::ClientError,
      OpenSSL::SSL::SSLError,
      Net::OpenTimeout,
      SocketError,
    ].freeze

    class_methods do
      def retry_on_network_errors(wait: 0.1.second, attempts: 3, &block)
        retry_on(*NETWORK_ERRORS, wait: wait, attempts: attempts, &block)
      end

      def retry_on(*exception, wait: 1.second, attempts: 3)
        rescue_from(*exception) do |error|
          if retry_count < attempts
            retry_calling(wait)
          elsif block_given?
            yield self, error
          else
            raise error
          end
        end
      end

      def discard_on(*exception)
        rescue_from(*exception) do |error|
          yield self, error if block_given?
        end
      end
    end

    def retry_calling(wait)
      sleep(wait)
      @retry_count += 1
      call(*args)
    end
  end
end
