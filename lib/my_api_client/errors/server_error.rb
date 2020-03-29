# frozen_string_literal: true

module MyApiClient
  # For 5xx server error
  class ServerError < Error
    # 500 Internal Server Error
    class InternalServerError < ServerError; end

    # 501 Not Implemented
    class NotImplemented < ServerError; end

    # 502 Bad Gateway
    class BadGateway < ServerError; end

    # 503 Service Unavailable
    class ServiceUnavailable < ServerError; end

    # 504 Gateway Timeout
    class GatewayTimeout < ServerError; end

    # 505 HTTP Version Not Supported
    class HttpVersionNotSupported < ServerError; end

    # 506 Variant Also Negotiates
    class VariantAlsoNegotiates < ServerError; end

    # 507 Insufficient Storage
    class InsufficientStorage < ServerError; end

    # 508 Loop Detected
    class LoopDetected < ServerError; end

    # 509 Bandwidth Limit Exceeded
    class BandwidthLimitExceeded < ServerError; end

    # 510 Not Extended
    class NotExtended < ServerError; end

    # 511 Network Authentication Required
    class NetworkAuthenticationRequired < ServerError; end
  end
end
