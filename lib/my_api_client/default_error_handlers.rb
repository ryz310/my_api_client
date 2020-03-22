# frozen_string_literal: true

module MyApiClient
  # Provides default error handlers.
  module DefaultErrorHandlers
    extend ActiveSupport::Concern

    # rubocop:disable Metrics/BlockLength
    included do
      # NOTE: The built-in error handlers are following. Although they are prepared
      #       to save the trouble of defining, but you can override any error handlers
      #       in your API client class.
      error_handling status_code: 400..499, raise: ClientError
      error_handling status_code: 400, raise: ClientError::BadRequest
      error_handling status_code: 401, raise: ClientError::Unauthorized
      error_handling status_code: 402, raise: ClientError::PaymentRequired
      error_handling status_code: 403, raise: ClientError::Forbidden
      error_handling status_code: 404, raise: ClientError::NotFound
      error_handling status_code: 405, raise: ClientError::MethodNotAllowed
      error_handling status_code: 406, raise: ClientError::NotAcceptable
      error_handling status_code: 407, raise: ClientError::ProxyAuthenticationRequired
      error_handling status_code: 408, raise: ClientError::RequestTimeout
      error_handling status_code: 409, raise: ClientError::Conflict
      error_handling status_code: 410, raise: ClientError::Gone
      error_handling status_code: 411, raise: ClientError::LengthRequired
      error_handling status_code: 412, raise: ClientError::PreconditionFailed
      error_handling status_code: 413, raise: ClientError::RequestEntityTooLarge
      error_handling status_code: 414, raise: ClientError::RequestUriTooLong
      error_handling status_code: 415, raise: ClientError::UnsupportedMediaType
      error_handling status_code: 416, raise: ClientError::RequestedRangeNotSatisfiable
      error_handling status_code: 417, raise: ClientError::ExpectationFailed
      error_handling status_code: 418, raise: ClientError::IamTeapot
      error_handling status_code: 421, raise: ClientError::MisdirectedRequest
      error_handling status_code: 422, raise: ClientError::UnprocessableEntity
      error_handling status_code: 423, raise: ClientError::Locked
      error_handling status_code: 424, raise: ClientError::FailedDependency
      error_handling status_code: 425, raise: ClientError::TooEarly
      error_handling status_code: 426, raise: ClientError::UpgradeRequired
      error_handling status_code: 428, raise: ClientError::PreconditionRequired
      error_handling status_code: 429, raise: ClientError::TooManyRequests
      error_handling status_code: 431, raise: ClientError::RequestHeaderFieldsTooLarge
      error_handling status_code: 451, raise: ClientError::UnavailableForLegalReasons

      error_handling status_code: 500..599, raise: ServerError
      error_handling status_code: 500, raise: ServerError::InternalServerError
      error_handling status_code: 501, raise: ServerError::NotImplemented
      error_handling status_code: 502, raise: ServerError::BadGateway
      error_handling status_code: 503, raise: ServerError::ServiceUnavailable
      error_handling status_code: 504, raise: ServerError::GatewayTimeout
      error_handling status_code: 505, raise: ServerError::HttpVersionNotSupported
      error_handling status_code: 506, raise: ServerError::VariantAlsoNegotiates
      error_handling status_code: 507, raise: ServerError::InsufficientStorage
      error_handling status_code: 508, raise: ServerError::LoopDetected
      error_handling status_code: 509, raise: ServerError::BandwidthLimitExceeded
      error_handling status_code: 510, raise: ServerError::NotExtended
      error_handling status_code: 511, raise: ServerError::NetworkAuthenticationRequired
    end
    # rubocop:enable Metrics/BlockLength
  end
end
