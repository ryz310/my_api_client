# frozen_string_literal: true

module MyApiClient
  module ErrorHandling
    extend ActiveSupport::Concern
    class_attribute :error_handlers, instance_writer: false, default: []

    class_methods do
      # Description of .error_handling
      #
      # @param status_code [String, Range, Integer] default: nil
      # @param json [Hash] default: nil
      # @param with [Symbol] default: nil
      # @return [Lambda, Symbol, nil] description_of_returned_object
      def error_handling(status_code: nil, json: nil, with: nil)
        error_handlers << lambda { |response|
          if match?(status_code, response.status) || match_all?(json, response.data)
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
        else
          false
        end
      end

      def match_all?(json, response_body)
        json.all? do |path, operator|
          # TODO: Use any jsonpath library.
          match?(operator, response_body.dig(*path.split('.')))
        end
      end
    end
  end
end
