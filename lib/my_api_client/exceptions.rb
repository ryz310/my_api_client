# frozen_string_literal: true

module MyApiClient
  module Exceptions
    extend ActiveSupport::Concern
    include ActiveSupport::Rescuable

    private

    attr_reader :retry_count, :method_name, :args

    class_methods do
      def retry_on(*exception, wait: 1.second, attempts: 3)
        rescue_from(*exception) do |error|
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

      def discard_on(*exception)
        rescue_from(*exception) do |error|
          if block_given?
            yield self, error
          else
            logger.error "Discarded #{self.class} due to a #{exception}. " \
                         "The original exception was #{error.cause.inspect}."
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
