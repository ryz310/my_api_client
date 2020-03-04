# frozen_string_literal: true

module MyErrors
  # 400 Bad Request
  class BadRequest < MyApiClient::ClientError; end

  # 401 Unauthorized
  class Unauthorized < MyApiClient::ClientError; end

  # 403 Forbidden
  class Forbidden < MyApiClient::ClientError; end
end
