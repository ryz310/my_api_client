# frozen_string_literal: true

module MyApiClient
  module Params
    # Description of Params
    class Request
      attr_reader :method, :uri, :headers, :body

      # Description of #initialize
      #
      # @param method [Symbol] describe_method_here
      # @param uri [URI] describe_uri_here
      # @param headers [Hash, Proc<Hash>, nil] describe_headers_here
      # @param body [Hash, Proc<Hash>, nil] describe_body_here
      def initialize(method, uri, headers, body)
        @method = method
        @uri = uri
        @headers = headers.is_a?(Proc) ? headers.call : headers
        @body = body.is_a?(Proc) ? body.call : body
      end

      # Description of #to_sawyer_args
      #
      # @return [Array<Object>] Arguments for Sawyer::Agent#call
      def to_sawyer_args
        [method, uri.to_s, body, { headers: headers }]
      end

      # Generate metadata for bugsnag.
      # Blank parameter will be omitted.
      #
      # @return [Hash] Metadata for bugsnag
      def metadata
        {
          line: "#{method.upcase} #{uri}",
          headers: headers,
          body: body,
        }.compact
      end
      alias to_bugsnag metadata

      # Returns contents as string for to be readable for human
      #
      # @return [String] Contents as string
      def inspect
        { method: method, uri: uri.to_s, headers: headers, body: body }.inspect
      end
    end
  end
end
