# frozen_string_literal: true

module MyApiClient
  # Sleep arbitrary time
  class Sleeper < ServiceAbstract
    # @param wait [Integer, Float] Sleep time
    def initialize(wait:)
      @wait = wait
    end

    private

    attr_reader :wait

    def call
      sleep(wait)
    end
  end
end
