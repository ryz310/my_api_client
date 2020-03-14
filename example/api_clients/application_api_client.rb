# frozen_string_literal: true

require_relative 'my_errors'

# An usage example of the `my_api_client`.
class ApplicationApiClient < MyApiClient::Base
  endpoint ENV['MY_API_ENDPOINT']

  self.logger = ::Logger.new(nil)

  http_open_timeout 2.seconds
  http_read_timeout 3.seconds

  retry_on MyApiClient::NetworkError, wait: 0.seconds, attempts: 3

  error_handling status_code: 400..499, raise: MyApiClient::ClientError
  error_handling status_code: 500..599 do |params, logger|
    logger.warn 'Server error occurred.'
    raise MyApiClient::ServerError, params
  end
end
