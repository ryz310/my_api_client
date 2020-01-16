# frozen_string_literal: true

module MyApiClient
  # Description of Exceptions
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

      retry_result
    end

    private

    attr_reader :retry_count, :retry_result, :method_name, :args

    class_methods do
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

      # Description of #discard_on
      #
      # @note
      #   !! It is implemented following ActiveJob, but I think this method is
      #   not useful in this gem. !!
      # @param exception [Type] describe_exception_here
      def discard_on(*exception)
        rescue_from(*exception) do |error|
          yield self, error if block_given?
        end
      end
    end

    def retry_calling(wait)
      Sleeper.call(wait: wait)
      @retry_count += 1
      @retry_result = call(*args)
    end
  end
end
