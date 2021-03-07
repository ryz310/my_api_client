# frozen_string_literal: true

module MyApiClient
  # Override lib/my_api_client/errors.rb for supporting Bugsnag breadcrumbs
  class Error < StandardError
    alias _original_initialize initialize

    # Override MyApiClient::Error#initialize
    def initialize(params, error_message = nil)
      _original_initialize(params, error_message)

      Bugsnag.leave_breadcrumb(
        "#{self.class.name} occurred",
        metadata.transform_values(&:inspect),
        Bugsnag::Breadcrumbs::ERROR_BREADCRUMB_TYPE
      )
    end
  end
end
