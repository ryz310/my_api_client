# frozen_string_literal: true

module MyErrors
  # 400 Bad Request
  class BadRequest < MyApiClient::ClientError; end

  # 401 Unauthorized
  class Unauthorized < MyApiClient::ClientError; end

  # 403 Forbidden
  class Forbidden < MyApiClient::ClientError; end

  # Error code: 0
  class ErrorCode00 < MyApiClient::ClientError; end

  # Error code: 10
  class ErrorCode10 < MyApiClient::ClientError; end

  # Error code: 20 to 29
  class ErrorCode2x < MyApiClient::ClientError; end

  # Error code: 30
  class ErrorCode30 < MyApiClient::ClientError; end

  # Error code: other
  class ErrorCodeOther < MyApiClient::ClientError; end
end
