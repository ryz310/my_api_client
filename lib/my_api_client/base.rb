# frozen_string_literal: true

module MyApiClient
  class Base
    include MyApiClient::Request
    include MyApiClient::Config
    include MyApiClient::ErrorHandling
  end
end
