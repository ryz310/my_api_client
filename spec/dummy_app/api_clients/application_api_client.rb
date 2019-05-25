# frozen_string_literal: true

class ApplicationApiClient < MyApiClient::Base
  request_timeout 3.seconds
  net_open_timeout 2.seconds

  retry_on MyApiClient::NetworkError, wait: 0.seconds, attempts: 3

  error_handling status_code: 400..499, raise: MyApiClient::ClientError
  error_handling status_code: 500..599 do |params, logger|
    logger.warn 'Server error occurred.'
    raise MyApiClient::ServerError, params
  end
end
