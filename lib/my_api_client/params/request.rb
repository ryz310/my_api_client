# frozen_string_literal: true

module MyApiClient
  module Params
    class Request
      attr_reader :method, :pathname, :headers, :query, :body

      def initialize(method, pathname, headers, query, body)
        @method = method
        @pathname = pathname
        @headers = headers
        @query = query
        @body = body
      end

      def to_sawyer_args
        [method, pathname, body, { headers: headers, query: query }]
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
