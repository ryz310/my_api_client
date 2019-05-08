# frozen_string_literal: true

module MyApiClient
  class Error < StandardError
    attr_reader :params

    def initialize(params, error_message = nil)
      @params = params
      super error_message
    end
  end
end
