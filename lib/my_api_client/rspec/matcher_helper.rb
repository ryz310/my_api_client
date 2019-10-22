# frozen_string_literal: true

module MyApiClient
  # Helper module for rspec custom matcher
  module MatcherHelper
    def disable_logging
      logger = instance_double(MyApiClient::Logger, info: nil, warn: nil)
      allow(MyApiClient::Logger).to receive(:new).and_return(logger)
    end

    def dummy_response(status: 200, headers: {}, body: nil)
      instance_double(
        Sawyer::Response,
        timing: 0.0,
        data: instance_double(Sawyer::Resource),
        status: status,
        headers: headers,
        body: body
      )
    end

    def diff_as_object(actual, expected)
      differ = RSpec::Support::Differ.new(
        object_preparer: ->(object) { RSpec::Matchers::Composable.surface_descriptions_in(object) },
        color: RSpec::Matchers.configuration.color?
      )
      differ.diff_as_object(actual, expected)
    end
  end
end
