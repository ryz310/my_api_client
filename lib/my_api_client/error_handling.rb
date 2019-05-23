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
      def error_handling(status_code: nil, json: nil, with: nil, &block)
        error_handlers << lambda { |response|
          if match?(status_code, response.status) || match_all?(json, response.body)
            return block_given? ? block : with || -> { raise MyApiClient::Error }
          end
        }
      end

      private

      def match?(operator, target)
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
        json&.all? do |path, operator|
          target = JsonPath.new(path).first(response_body)
          match?(operator, target)
        end
      end
    end
  end
end
