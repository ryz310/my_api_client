# frozen_string_literal: true

module MyApiClient
  class Base
    include MyApiClient::Request
    include MyApiClient::Config

    def self.error_handling(status_code: nil, json: nil, with: nil)
      # TODO: Implemnt this
    end
  end
end
