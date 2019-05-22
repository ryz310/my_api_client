# frozen_string_literal: true

require 'net/http'

class ApplicationApiClient < MyApiClient::Base
  request_timeout 3.seconds
  net_open_timeout 2.seconds

  class IgnorableError < MyApiClient::Error; end

  retry_on_network_errors wait: 0.1.seconds do |_client, error, logger|
    logger.warn error.message
  end

  error_handling status_code: 500..999 do |params|
    raise IgnorableError, params
  end
end
