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
      Sleeper.call(wait:)
      @retry_count += 1
      @retry_result = call(*args)
    end

    # call the handler for exception
    #
    # @note
    #   To avoid handling the exception of the retry origin on the second and subsequent retries,
    #   make exception.cause visited.
    # @override ActiveSupport::Rescuable#rescue_with_handler
    # @param exception [Exception] Target exception
    def rescue_with_handler(exception)
      self.class.rescue_with_handler(exception, object: self, visited_exceptions: [exception.cause])
    end
  end
end
