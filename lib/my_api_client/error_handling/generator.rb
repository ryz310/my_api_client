# frozen_string_literal: true

module MyApiClient
  module ErrorHandling
    # Generates an error handler proc (or symbol)
    class Generator < ServiceAbstract
      ARGUMENTS = %i[instance response status_code headers json with raise block].freeze

      # @param options [Hash]
      #   Options for this generator
      # @option instance [MyApiClient::Base]
      #   The API client class.
      # @option response [Sawyer::Response]
      #   The target of verifying
      # @option status_code [String, Range, Integer, Regexp]
      #   Verifies response HTTP status code and raises error if matched
      # @option headers [String, Regexp]
      #   Verifies response HTTP header and raises error if matched
      # @option json [Hash, Symbol]
      #   Verifies response body as JSON and raises error if matched.
      #   If specified `:forbid_nil`, it forbid `nil` on response_body.
      # @option with [Symbol]
      #   Calls specified method when error detected
      # @option raise [MyApiClient::Error]
      #   Raises specified error when error detected. default: MyApiClient::Error
      # @option block [Proc]
      #   Executes the block when error detected
      # @return [Proc, nil]
      #   Returns the error handler as "Proc". If no error occurs, return `nil`.
      def initialize(**options)
        options[:raise] ||= MyApiClient::Error
        verify_and_set_arguments(**options)
      end

      private

      attr_reader(*ARGUMENTS.map { |argument| :"_#{argument}" })

      def call
        return unless match?(_status_code, _response.status)
        return unless match_headers?(_headers, _response.headers)
        return unless match_body?(_json, _response.body)

        generate_error_handler
      end

      def generate_error_handler
        if _block
          block_caller
        elsif _with
          method_caller
        else
          error_raiser
        end
      end

      def block_caller
        lambda { |params, logger|
          _block.call(params, logger)
          error_raiser.call(params, logger)
        }
      end

      def method_caller
        lambda { |params, logger|
          _instance.send(_with, params, logger)
          error_raiser.call(params, logger)
        }
      end

      def error_raiser
        ->(params, _) { raise _raise, params }
      end

      # Verify given options and raise error if they are incorrect.
      # If not, set them to instance variables.
      #
      # @param options [Hash]
      # @raise [RuntimeError]
      def verify_and_set_arguments(**options)
        options.each do |k, v|
          if ARGUMENTS.exclude? k
            raise "Specified an incorrect option: `#{k}`\n" \
                  "You can use options that: #{ARGUMENTS}"
          end

          instance_variable_set("@_#{k}", v)
        end
      end

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

      def match_headers?(headers, response_headers)
        return true if headers.nil?
        return false if response_headers.blank?

        headers.all? do |header_key, operator|
          target = response_headers[header_key]
          match?(operator, target)
        end
      end

      def match_body?(json, response_body)
        return true if json.nil?
        return response_body.nil? if json == :forbid_nil
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
