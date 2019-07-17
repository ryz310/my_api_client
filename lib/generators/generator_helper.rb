# frozen_string_literal: true

# The helper module for source generators
module MyApiClient
  module GeneratorHelper
    def yeild_request_arguments
      requests.each do |request|
        http_method, pathname = request.split(':')
        action = "#{http_method}_#{pathname.tr('/', '_')}"
        yield action, http_method, pathname
      end
    end
  end
end
