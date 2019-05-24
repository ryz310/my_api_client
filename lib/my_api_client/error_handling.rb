# frozen_string_literal: true

module MyApiClient
  module ErrorHandling
    extend ActiveSupport::Concern

    class_methods do
      # Description of .error_handling
      #
      # @param status_code [String, Range, Integer, Regexp] default: nil
      # @param json [Hash] default: nil
      # @param with [Symbol] default: nil
      # @param raise [MyApiClient::Error] default: MyApiClient::Error
      # @param block [Proc] describe_block_here
      def error_handling(status_code: nil, json: nil, with: nil, raise: MyApiClient::Error, &block)
        error_handlers << lambda { |response|
          if match?(status_code, response.status) && match_all?(json, response.body)
            if block_given?
              ->(params, logger) { yield params, logger }
            elsif with
              with
            else
              ->(params, _logger) { raise raise, params }
            end
          end
        }
      end

      private

      def match?(operator, target)
        return true if operator.nil?

        case operator
        when String, Integer
          operator == target
        when Range
          operator.include?(target)
        when Regexp
          operator =~ target.to_s
        else
          false
        end
      end

      def match_all?(json, response_body)
        return true if json.nil?

        json.all? do |path, operator|
          target = JsonPath.new(path.to_s).first(response_body)
          match?(operator, target)
        end
      end
    end
  end
end
