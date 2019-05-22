# frozen_string_literal: true

module MyApiClient
  class Base
    include MyApiClient::Request
    include MyApiClient::Config

    class_attribute :error_handlers, instance_writer: false, default: []

    # Description of .error_handling
    #
    # @param status_code [String, Range, Integer] default: nil
    # @param json [Hash] default: nil
    # @param with [Symbol] default: nil
    # @return [Lambda, Symbol, nil] description_of_returned_object
    def self.error_handling(status_code: nil, json: nil, with: nil)
      error_handlers << lambda { |response|
        if match?(status_code, response.status) || match_all?(json, response.data)
          return block_given? ? block : with || -> { raise MyApiClient::Error }
        end
      }
    end

    def self.match?(operator, target)
      case operator
      when String, Integer
        operator == target
      when Range
        operator.include?(target)
      else
        false
      end
    end

    def self.match_all?(json, response_body)
      json.all? do |path, operator|
        # TODO: Use any jsonpath library.
        match?(operator, response_body.dig(*path.split('.')))
      end
    end
  end
end
