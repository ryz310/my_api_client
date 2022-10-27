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

  # Header: X-First-Header is invalid
  class FirstHeaderIsInvalid < MyApiClient::ClientError; end

  # Header: X-First-Header is 100 to 199
  class FirstHeaderIs1xx < MyApiClient::ClientError; end

  # Header: X-First-Header is 0
  class FirstHeaderIs00 < MyApiClient::ClientError; end

  # Header: X-First-Header is 30
  class FirstHeaderIs30 < MyApiClient::ClientError; end

  # Header: X-First-Header is 30 and status is 400
  class FirstHeaderIs30WithNotFound < MyApiClient::ClientError; end

  # Header: X-First-Header is 200 to 299 and X-Second-Header is 300 to 399
  class MultipleHeaderIsInvalid < MyApiClient::ClientError; end
end
