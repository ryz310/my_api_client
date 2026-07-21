# frozen_string_literal: true

module MyApiClient
  # For 4xx client error
  class ClientError < Error
    # 400 Bad Request
    class BadRequest < ClientError; end

    # 401 Unauthorized
    class Unauthorized < ClientError; end

    # 402 Payment Required
    class PaymentRequired < ClientError; end

    # 403 Forbidden
    class Forbidden < ClientError; end

    # 404 Not Found
    class NotFound < ClientError; end

    # 405 Method Not Allowed
    class MethodNotAllowed < ClientError; end

    # 406 Not Acceptable
    class NotAcceptable < ClientError; end

    # 407 Proxy Authentication Required
    class ProxyAuthenticationRequired < ClientError; end

    # 408 Request Timeout
    class RequestTimeout < ClientError; end

    # 409 Conflict
    class Conflict < ClientError; end

    # 410 Gone
    class Gone < ClientError; end

    # 411 Length Required
    class LengthRequired < ClientError; end

    # 412 Precondition Failed
    class PreconditionFailed < ClientError; end

    # 413 Payload Too Large
    class RequestEntityTooLarge < ClientError; end

    # 414 URI Too Long
    class RequestUriTooLong < ClientError; end

    # 415 Unsupported Media Type
    class UnsupportedMediaType < ClientError; end

    # 416 Range Not Satisfiable
    class RequestedRangeNotSatisfiable < ClientError; end

    # 417 Expectation Failed
    class ExpectationFailed < ClientError; end

    # 418 I'm a teapot
    class IamTeapot < ClientError; end

    # 421 Misdirected Request
    class MisdirectedRequest < ClientError; end

    # 422 Unprocessable Entity (Deprecated)
    class UnprocessableEntity < ClientError; end

    # 422 Unprocessable Content
    class UnprocessableContent < UnprocessableEntity; end
    deprecate_constant :UnprocessableEntity

    # 423 Locked
    class Locked < ClientError; end

    # 424 Failed Dependency
    class FailedDependency < ClientError; end

    # 425 Too Early
    class TooEarly < ClientError; end

    # 426 Upgrade Required
    class UpgradeRequired < ClientError; end

    # 428 Precondition Required
    class PreconditionRequired < ClientError; end

    # 429 Too Many Requests
    class TooManyRequests < ClientError; end

    # 431 Request Header Fields Too Large
    class RequestHeaderFieldsTooLarge < ClientError; end

    # 451 Unavailable for Legal Reasons
    class UnavailableForLegalReasons < ClientError; end
  end
end
