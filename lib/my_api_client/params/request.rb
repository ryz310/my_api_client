# frozen_string_literal: true

module MyApiClient
  module Params
    # Description of Params
    class Request
      attr_reader :method, :pathname, :headers, :query, :body

      # Description of #initialize
      #
      # @param method [Symbol] describe_method_here
      # @param pathname [String] describe_pathname_here
      # @param headers [Hash, nil] describe_headers_here
      # @param query [Hash, nil] describe_query_here
      # @param body [Hash, nil] describe_body_here
      def initialize(method, pathname, headers, query, body)
        @method = method
        @pathname = pathname
        @headers = headers
        @query = query
        @body = body
      end

      # Description of #to_sawyer_args
      #
      # @return [Array<Object>] Arguments for Sawyer::Agent#call
      def to_sawyer_args
        [method, pathname, body, { headers: headers, query: query }]
      end

      # Generate metadata for bugsnag.
      # Blank parameter will be omitted.
      #
      # @return [Hash] Metadata for bugsnag
      def to_bugsnag
        {
          line: "#{method.upcase} #{pathname}",
          headers: headers,
          query: query,
          body: body,
        }.compact
      end

      # Returns contents as string for to be readable for human
      #
      # @return [String] Contents as string
      def inspect
        { method: method, pathname: pathname, headers: headers, query: query, body: body }.inspect
      end
    end
  end
end
