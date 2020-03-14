# frozen_string_literal: true

require_relative 'application_api_client'

# An usage example of the `my_api_client`.
# See also: my_api/app/controllers/status_controller.rb
class MyErrorApiClient < ApplicationApiClient
  error_handling json: { '$.error.message': /You requested error code/ },
                 raise: MyErrors::ErrorCodeOther

  error_handling json: { '$.error.code': :zero? },
                 raise: MyErrors::ErrorCode00

  error_handling json: { '$.error.code': 10 },
                 raise: MyErrors::ErrorCode10

  error_handling json: { '$.error.code': 20..29 },
                 raise: MyErrors::ErrorCode2x

  error_handling json: { '$.error.code': 30 },
                 status_code: 400,
                 raise: MyErrors::ErrorCode30

  # GET error/:code
  def get_error(code:)
    get "error/#{code}", headers: headers
  end

  private

  def headers
    { 'Content-Type': 'application/json;charset=UTF-8' }
  end
end
