# frozen_string_literal: true

require_relative 'my_errors'

# An usage example of the `my_api_client`.
class ApplicationApiClient < MyApiClient::Base
  endpoint ENV['MY_API_ENDPOINT']

  self.logger = ::Logger.new(nil)

  http_open_timeout 5.seconds
  http_read_timeout 5.seconds
end
