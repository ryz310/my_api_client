# frozen_string_literal: true

if defined? Bugsnag && Bugsnag::VERSION >= '6.11.0'
  require 'bugsnag'
  module MyApiClient
    # Override lib/my_api_client/errors.rb for supporting Bugsnag breadcrumbs
    class Error < StandardError
      alias _original_initialize initialize

      # Override MyApiClient::Error#initialize
      def initialize(params, error_message = nil)
        _original_initialize(params, error_message)

        Bugsnag.leave_breadcrumb(
          "#{self.class.name} occurred",
          metadata,
          Bugsnag::Breadcrumbs::ERROR_BREADCRUMB_TYPE
        )
      end
    end
  end
end
