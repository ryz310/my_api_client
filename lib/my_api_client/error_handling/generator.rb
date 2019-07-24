# frozen_string_literal: true

module MyApiClient
  module ErrorHandling
    # Generates an error handler proc (or symbol)
    class Generator
      private_class_method :new

      # @param options [Hash]
      #   Options for this generator
      # @option response [Sawyer::Response]
      #   The target of verifying
      # @option status_code [String, Range, Integer, Regexp]
      #   Verifies response HTTP status code and raises error if matched
      # @option json [Hash]
      #   Verifies response body as JSON and raises error if matched
      # @option with [Symbol]
      #   Calls specified method when error detected
      # @option raise [MyApiClient::Error]
      #   Raises specified error when error detected. default: MyApiClient::Error
      # @option block [Proc]
      #   Executes the block when error detected
      # @return [Proc]
      #   Returns value as `Proc` if given `raise` or `block` option
      # @return [Symbol]
      #   Returns value as `Symbol` if given `with` option
      def self.call(**options)
        new(options).send(:call)
      end

      private

      attr_reader :_response, :_status_code, :_json, :_with, :_raise, :_block

      def initialize(**options)
        options.each { |k, v| instance_variable_set("@_#{k}", v) }
      end

      def call
        return unless match?(_status_code, _response.status)
        return unless match_all?(_json, _response.body)

        if _block
          ->(params, logger) { _block.call(params, logger) }
        elsif _with
          _with
        else
          ->(params, _logger) { raise _raise, params }
        end
      end

      # rubocop:disable Metrics/CyclomaticComplexity
      def match?(operator, target)
        case operator
        when nil
          true
        when String, Integer, TrueClass, FalseClass
          operator == target
        when Range
          operator.include?(target)
        when Regexp
          operator =~ target.to_s
        when Symbol
          target.respond_to?(operator) && target.public_send(operator)
        else
          raise "Unexpected operator type was given: #{operator.inspect}"
        end
      end
      # rubocop:enable Metrics/CyclomaticComplexity

      def match_all?(json, response_body)
        return true if json.nil?
        return false if response_body.blank?

        json.all? do |path, operator|
          target = JsonPath.new(path.to_s).first(response_body)
          match?(operator, target)
        end
      rescue MultiJson::ParseError
        false
      end
    end
  end
end
