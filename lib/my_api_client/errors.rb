# frozen_string_literal: true

module MyApiClient
  class Error < StandardError
    attr_reader :params

    def initialize(params, error_message = nil)
      @params = params
      super error_message
    end

    # Returns contents as string for to be readable for human
    #
    # @return [String] Contents as string
    def inspect
      { error: super, params: params }.inspect
    end
  end
end
